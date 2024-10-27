package main

import (
	"bytes"
	"context"
	"encoding/base64"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"net/url"
	"os"
	"path/filepath"
	"strings"
	"time"
	_ "time/tzdata"

	"tidbyt.dev/pixlet/encode"
	"tidbyt.dev/pixlet/runtime"
)

var (
	cache     = runtime.NewInMemoryCache()
	healthURL = flag.String("health", "", "perform health check for the given URL and exit")
	appCache  = map[string]*runtime.Applet{}

	errUnknownContentType = errors.New("unknown content type")
	errInvalidFileName    = errors.New("invalid file name")
)

const (
	tidbytBaseURL = "https://api.tidbyt.com"
	silenceOutput = false
	renderGif     = false
	timeout       = 30 * time.Second
	maxDuration   = 15 * time.Second
)

type (
	pushRequest struct {
		Content     string            `json:"content"`
		DeviceID    string            `json:"deviceid"`
		Token       string            `json:"token"`
		ContentType string            `json:"contenttype"`
		Arguments   map[string]string `json:"starargs"`
	}

	publishRequest struct {
		Content        string            `json:"content"`
		DeviceID       string            `json:"deviceid"`
		Token          string            `json:"token"`
		InstallationID string            `json:"contentid"`
		PublishType    string            `json:"publishtype"`
		ContentType    string            `json:"contenttype"`
		Arguments      map[string]string `json:"starargs"`
	}

	textRequest struct {
		Content    string `json:"content"`
		DeviceID   string `json:"deviceid"`
		Token      string `json:"token"`
		TextType   string `json:"texttype"`
		Font       string `json:"font"`
		Color      string `json:"color"`
		Title      string `json:"title"`
		TitleColor string `json:"titlecolor"`
		TitleFont  string `json:"titlefont"`
	}

	tidbytPushRequest struct {
		Image          string `json:"image"`
		InstallationID string `json:"installationID,omitempty"`
		Background     bool   `json:"background"`
	}

	options struct {
		LogLevel string `json:"log_level"`
	}
)

func pushHandler(w http.ResponseWriter, req *http.Request) {
	var r pushRequest

	if err := json.NewDecoder(req.Body).Decode(&r); err != nil {
		http.Error(w, fmt.Sprintf("failed to decode push request: %v", err), http.StatusBadRequest)
		return
	}

	slog.Debug(fmt.Sprintf("Received push request %+v", r))

	if err := pushApp(r.ContentType, r.Content, r.Arguments, r.DeviceID, "", r.Token, false); err != nil {
		handleHTTPError(w, err)
	}
}

func publishHandler(w http.ResponseWriter, req *http.Request) {
	var r publishRequest

	if err := json.NewDecoder(req.Body).Decode(&r); err != nil {
		http.Error(w, fmt.Sprintf("failed to decode publish request: %v", err), http.StatusBadRequest)
		return
	}

	slog.Debug(fmt.Sprintf("Received publish request %+v", r))

	background := r.PublishType == "background"
	if err := pushApp(r.ContentType, r.Content, r.Arguments, r.DeviceID, r.InstallationID, r.Token, background); err != nil {
		handleHTTPError(w, err)
	}
}

func textHandler(w http.ResponseWriter, req *http.Request) {
	var r textRequest

	if err := json.NewDecoder(req.Body).Decode(&r); err != nil {
		http.Error(w, fmt.Sprintf("failed to decode text request: %v", err), http.StatusBadRequest)
		return
	}

	slog.Debug(fmt.Sprintf("Received text request %+v", r))

	if r.TextType == "" {
		http.Error(w, "missing \"texttype\"", http.StatusBadRequest)
		return
	}

	contentName := fmt.Sprintf("text-%s", r.TextType)
	config := map[string]string{
		"content": r.Content,
		"font":    r.Font,
		"color":   r.Color,
	}
	if r.TextType == "title" {
		config["title"] = r.Title
		config["titlecolor"] = r.TitleColor
		config["titlefont"] = r.TitleFont
	}

	if err := pushApp("builtin", contentName, config, r.DeviceID, "", r.Token, false); err != nil {
		handleHTTPError(w, err)
	}
}

func healthHandler(w http.ResponseWriter, req *http.Request) {
	w.WriteHeader(http.StatusOK)
}

func handleHTTPError(w http.ResponseWriter, err error) {
	status := http.StatusInternalServerError
	if errors.Is(err, errInvalidFileName) || errors.Is(err, errUnknownContentType) {
		status = http.StatusBadRequest
	}
	slog.Error(err.Error())
	http.Error(w, err.Error(), status)
}

func pushApp(contentType, contentName string, arguments map[string]string, deviceID, installationID, token string, background bool) error {
	var rootDir string
	cache := false
	switch contentType {
	case "builtin":
		rootDir = "/display"
		cache = true
	case "custom":
		rootDir = "/homeassistant/tidbyt"
	default:
		return fmt.Errorf("%w: %q", errUnknownContentType, contentType)
	}

	if !validatePath(contentName) {
		return errInvalidFileName
	}

	path := filepath.Join(rootDir, contentName)
	image, err := renderApp(path, arguments, cache)
	if err != nil {
		return fmt.Errorf("failed to render app: %v", err)
	}

	if err := tidbytPush(image, deviceID, installationID, token, background); err != nil {
		return fmt.Errorf("failed to push image: %v", err)
	}

	slog.Info(fmt.Sprintf("Pushed %v", path))

	return nil
}

func tidbytPush(imageData []byte, deviceID, installationID, apiToken string, background bool) error {
	payload, err := json.Marshal(
		tidbytPushRequest{
			Image:          base64.StdEncoding.EncodeToString(imageData),
			InstallationID: installationID,
			Background:     background,
		},
	)
	if err != nil {
		return fmt.Errorf("failed to marshal json: %w", err)
	}
	u := fmt.Sprintf("%s/v0/devices/%s/push", tidbytBaseURL, url.PathEscape(deviceID))
	if err := tidbytAPI(u, "POST", payload, apiToken); err != nil {
		return fmt.Errorf("failed to push image: %w", err)
	}
	return nil
}

func tidbytAPI(u, method string, payload []byte, apiToken string) error {
	req, err := http.NewRequest(method, u, bytes.NewReader(payload))
	if err != nil {
		return fmt.Errorf("creating %v request: %w", method, err)
	}

	req.Header.Add("Authorization", fmt.Sprintf("Bearer %s", apiToken))

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return fmt.Errorf("pushing to API: %w", err)
	}

	if resp.StatusCode != http.StatusOK {
		slog.Error(fmt.Sprintf("Tidbyt API returned status %s\n", resp.Status))
		body, _ := io.ReadAll(resp.Body)
		slog.Error(string(body))
		return fmt.Errorf("tidbyt API returned status: %s", resp.Status)
	}

	return nil
}

func renderApp(path string, config map[string]string, cache bool) ([]byte, error) {
	applet := appCache[path]

	if applet == nil {
		// check if path exists
		info, err := os.Stat(path)
		if err != nil {
			// legacy: try a single file with ".star" appended
			info, err = os.Stat(path + ".star")
			if err != nil {
				return nil, fmt.Errorf("failed to stat %s: %w", path, err)
			}
		}

		// Remove the print function from the starlark thread if the silent flag is
		// passed.
		var opts []runtime.AppletOption
		if silenceOutput {
			opts = append(opts, runtime.WithPrintDisabled())
		}

		if info.IsDir() {
			fs := os.DirFS(path)
			applet, err = runtime.NewAppletFromFS(filepath.Base(path), fs, opts...)
		} else {
			var srcBytes []byte
			srcBytes, err = os.ReadFile(path)
			if err != nil {
				return nil, fmt.Errorf("failed to read %s: %w", path, err)
			}

			applet, err = runtime.NewApplet(filepath.Base(path), srcBytes, opts...)
		}
		if err != nil {
			return nil, fmt.Errorf("failed to load applet: %w", err)
		}

		if cache {
			appCache[path] = applet
		}
	}

	ctx := context.Background()
	if timeout > 0 {
		ctx, _ = context.WithTimeoutCause(
			ctx,
			timeout,
			fmt.Errorf("timeout after %v", timeout),
		)
	}

	roots, err := applet.RunWithConfig(ctx, config)
	if err != nil {
		return nil, fmt.Errorf("error running script: %w", err)
	}
	screens := encode.ScreensFromRoots(roots)

	var buf []byte

	duration := maxDuration
	if screens.ShowFullAnimation {
		duration = 0 * time.Millisecond
	}

	if renderGif {
		buf, err = screens.EncodeGIF(int(duration.Milliseconds()))
	} else {
		buf, err = screens.EncodeWebP(int(duration.Milliseconds()))
	}
	if err != nil {
		return nil, fmt.Errorf("error rendering: %w", err)
	}

	return buf, nil
}

func checkHealth(url string) error {
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return fmt.Errorf("creating GET request: %w", err)
	}

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return err
	}

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("unhealthy status: %d", resp.StatusCode)
	}

	return nil
}

func validatePath(path string) bool {
	return !strings.Contains(path, "/") && !strings.Contains(path, "\\") && !strings.Contains(path, "..")
}

func parseOptions() {
	optionsJSON, err := os.ReadFile("/data/options.json")
	if err != nil {
		if !os.IsNotExist(err) {
			slog.Error(fmt.Sprintf("error reading /data/options: %v", err))
		}
		return
	}

	opt := options{}
	if err := json.Unmarshal(optionsJSON, &opt); err != nil {
		slog.Error(fmt.Sprintf("error parsing /data/options: %v", err))
		return
	}

	switch opt.LogLevel {
	case "debug":
		slog.SetLogLoggerLevel(slog.LevelDebug)
	case "info":
		slog.SetLogLoggerLevel(slog.LevelInfo)
	case "warning":
		slog.SetLogLoggerLevel(slog.LevelWarn)
	case "error":
		slog.SetLogLoggerLevel(slog.LevelError)
	default:
		slog.Error(fmt.Sprintf("invalid log level: %s", opt.LogLevel))
	}
}

func main() {
	flag.Parse()

	parseOptions()

	if *healthURL != "" {
		if err := checkHealth(*healthURL); err != nil {
			slog.Error(fmt.Sprintf("Health check failed: %v", err))
			os.Exit(1)
		}
		os.Exit(0)
	}

	runtime.InitHTTP(cache)
	runtime.InitCache(cache)

	http.HandleFunc("POST /tidbyt-push", pushHandler)
	http.HandleFunc("POST /tidbyt-publish", publishHandler)
	http.HandleFunc("POST /tidbyt-text", textHandler)
	http.HandleFunc("GET /health", healthHandler)

	slog.Info("Starting TidbytAssistant server")
	if err := http.ListenAndServe(":9000", nil); err != nil {
		slog.Error(fmt.Sprintf("Failed to start server: %v", err))
	}
}
