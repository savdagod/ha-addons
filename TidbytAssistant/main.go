package main

import (
	"bytes"
	"context"
	"encoding/base64"
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"log"
	"net/http"
	"net/url"
	"os"
	"path/filepath"
	"strings"
	"time"

	"tidbyt.dev/pixlet/encode"
	"tidbyt.dev/pixlet/runtime"
)

var (
	cache     = runtime.NewInMemoryCache()
	healthURL = flag.String("health", "", "perform health check for the given URL and exit")
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
		Content     string   `json:"content"`
		DeviceID    string   `json:"deviceid"`
		Token       string   `json:"token"`
		ContentType string   `json:"contenttype"`
		Arguments   []string `json:"starargs"`
	}

	publishRequest struct {
		Content        string   `json:"content"`
		DeviceID       string   `json:"deviceid"`
		Token          string   `json:"token"`
		InstallationID string   `json:"contentid"`
		PublishType    string   `json:"publishtype"`
		Arguments      []string `json:"starargs"`
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

	deleteRequest struct {
		InstallationID string `json:"contentid"`
		DeviceID       string `json:"deviceid"`
		Token          string `json:"token"`
	}

	tidbytPushRequest struct {
		Image          string `json:"image"`
		InstallationID string `json:"installationID,omitempty"`
		Background     bool   `json:"background"`
	}
)

func pushHandler(w http.ResponseWriter, req *http.Request) {
	var r pushRequest

	if err := json.NewDecoder(req.Body).Decode(&r); err != nil {
		http.Error(w, fmt.Sprintf("failed to decode push request: %v", err), http.StatusBadRequest)
		return
	}

	var rootDir string
	switch r.ContentType {
	case "builtin":
		rootDir = "/display"
	case "custom":
		rootDir = "/homeassistant/tidbyt"
	default:
		http.Error(w, fmt.Sprintf("unknown content type %q", r.ContentType), http.StatusBadRequest)
	}

	config, err := parseArguments(r.Arguments)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	path := filepath.Join(rootDir, r.Content+".star")
	if err := renderAndPush(path, config, r.DeviceID, "", r.Token, false); err != nil {
		log.Print(err.Error())
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
}

func publishHandler(w http.ResponseWriter, req *http.Request) {
	var r publishRequest

	if err := json.NewDecoder(req.Body).Decode(&r); err != nil {
		http.Error(w, fmt.Sprintf("failed to decode publish request: %v", err), http.StatusBadRequest)
		return
	}

	config, err := parseArguments(r.Arguments)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	path := filepath.Join("/homeassistant/tidbyt", r.Content+".star")
	background := r.PublishType == "background"

	if err := renderAndPush(path, config, r.DeviceID, r.InstallationID, r.Token, background); err != nil {
		log.Print(err.Error())
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

func textHandler(w http.ResponseWriter, req *http.Request) {
	var r textRequest

	if err := json.NewDecoder(req.Body).Decode(&r); err != nil {
		http.Error(w, fmt.Sprintf("failed to decode text request: %v", err), http.StatusBadRequest)
		return
	}
	if r.TextType == "" {
		http.Error(w, "missing \"texttype\"", http.StatusBadRequest)
		return
	}

	path := filepath.Join("/display", fmt.Sprintf("text-%s.star", r.TextType))
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

	if err := renderAndPush(path, config, r.DeviceID, "", r.Token, false); err != nil {
		log.Println(path)
		log.Print(err.Error())
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

func deleteHandler(w http.ResponseWriter, req *http.Request) {
	var r deleteRequest

	if err := json.NewDecoder(req.Body).Decode(&r); err != nil {
		http.Error(w, fmt.Sprintf("failed to decode delete request: %v", err), http.StatusBadRequest)
		return
	}

	u := fmt.Sprintf(
		"%s/v0/devices/%s/installations/%s",
		tidbytBaseURL,
		r.DeviceID,
		r.InstallationID,
	)
	if err := tidbytAPI(u, "DELETE", nil, r.Token); err != nil {
		log.Print(err.Error())
		http.Error(w, fmt.Sprintf("failed to delete: %v", err), http.StatusInternalServerError)
		return
	}
}

func healthHandler(w http.ResponseWriter, req *http.Request) {
	w.WriteHeader(http.StatusOK)
}

func renderAndPush(path string, arguments map[string]string, deviceID, installationID, token string, background bool) error {
	image, err := renderApp(path, arguments)
	if err != nil {
		return fmt.Errorf("failed to render app: %v", err)
	}

	if err := tidbytPush(image, deviceID, installationID, token, background); err != nil {
		return fmt.Errorf("failed to push image: %v", err)
	}

	log.Printf("Pushed %v", path)

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
		fmt.Printf("Tidbyt API returned status %s\n", resp.Status)
		body, _ := io.ReadAll(resp.Body)
		fmt.Println(string(body))
		return fmt.Errorf("Tidbyt API returned status: %s", resp.Status)
	}

	return nil
}

func parseArguments(args []string) (map[string]string, error) {
	config := map[string]string{}
	for _, param := range args {
		split := strings.Split(param, "=")
		if len(split) < 2 {
			return nil, fmt.Errorf("parameters must be in form <key>=<value>, found %s", param)
		}
		config[split[0]] = strings.Join(split[1:], "=")
	}

	return config, nil
}

func renderApp(path string, config map[string]string) ([]byte, error) {
	// check if path exists
	_, err := os.Stat(path)
	if err != nil {
		return nil, fmt.Errorf("failed to stat %s: %w", path, err)
	}

	// Remove the print function from the starlark thread if the silent flag is
	// passed.
	var opts []runtime.AppletOption
	if silenceOutput {
		opts = append(opts, runtime.WithPrintDisabled())
	}

	ctx := context.Background()
	if timeout > 0 {
		ctx, _ = context.WithTimeoutCause(
			ctx,
			timeout,
			fmt.Errorf("timeout after %v", timeout),
		)
	}

	srcBytes, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("failed to read %s: %w", path, err)
	}

	applet, err := runtime.NewApplet(filepath.Base(path), srcBytes, opts...)
	if err != nil {
		return nil, fmt.Errorf("failed to load applet: %w", err)
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

func main() {
	flag.Parse()

	if *healthURL != "" {
		if err := checkHealth(*healthURL); err != nil {
			log.Printf("Health check failed: %v", err)
			os.Exit(1)
		}
		os.Exit(0)
	}

	runtime.InitHTTP(cache)
	runtime.InitCache(cache)

	http.HandleFunc("POST /tidbyt-push", pushHandler)
	http.HandleFunc("POST /tidbyt-publish", publishHandler)
	http.HandleFunc("POST /tidbyt-text", textHandler)
	http.HandleFunc("POST /tidbyt-delete", deleteHandler)
	http.HandleFunc("GET /health", healthHandler)

	if err := http.ListenAndServe(":9000", nil); err != nil {
		log.Printf("Failed to start server: %v", err)
	}
}
