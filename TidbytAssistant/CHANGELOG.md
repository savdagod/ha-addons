# Changelog

## 1.0.16

- The base URL used to push rendered images to a server is now configurable. This can be used to switch from Tidbyt's server to API-compatible alternatives like https://github.com/tavdog/tronbyt-server.

## 1.0.15

- Fix filename used in legacy code path for single-file apps.

## 1.0.14

- Consolidate Push and Publish services into 1 to avoid redundancy. This is a breaking change so all automations using the Publish service needs to migrate to using the Push service. You should be able to just rename Publish to Push and all the config values should transfer over.
- Added apps.json list, used by the integration to dynamically update services.yaml. This avoids needing to update the integration when a built-in app is added.
- **NOTE: Be sure to update the integration to v1.0.13**

## 1.0.13

- Support publishing built-in content. Added new content for publishing.
- **NOTE: Be sure to update the integration to v1.0.11**

## 1.0.12

- Added config to main in built-in files to configure language from Push service.

## 1.0.11

- Added option to set the log level.

## 1.0.10

- Fixed timezone not found error when rendering apps with timezones.

## 1.0.9

- Reduced size of the addon by running a distroless container with a static Go server.
- **NOTE: Be sure to update the integration to v1.0.7**

## 1.0.8

- Use command line arguments for text scripts instead of replacing strings.
- Add Text & Title type for Text service.
- Publish service now pushes to the background, preventing the current app from being replaced by the pushed app.
- Push and Publish service now support key=value pair arguments.
- Scripts clear tmp folder before rather than after commands.
- Moved scripts to their own folder.

## 1.0.7

- Added option to publish from background or foreground.
- **NOTE: Be sure to update the integration to v1.0.5 to be able to use this feature!**

## 1.0.6

- Use command line arguments for text scripts instead of replacing strings.
- Add Text & Title type for Text service.
- Publish service now pushes to the background, preventing the current app from being replaced by the pushed app.
- Push and Publish service now support key=value pair arguments.
- Scripts clear tmp folder before rather than after commands.
- Moved scripts to their own folder.
- Point pixlet build to forked repo to keep Pixlet version consistent.
- Add error handling to scripts, webhook responds with error which will be logged in HomeAssistant.
- **NOTE: Be sure to update the integration to v1.0.4 to take advantage of these new features!**

## 1.0.5

- Change Dockerfile to build pixlet binary.
- Edit scripts to move .star files to tmp directory to work around current bug in pixlet.

## 1.0.4

- Added libwep to image.

## 1.0.3

- Added full path for pixlet app to potentially fix script not finding pixlet app.

## 1.0.2

- Fix to Dockerfile for those building on arm64 architecture.
- Added new service TidbytAssistant: Delete, which allows you to delete apps using their content IDs.
- Be sure to download the most up to date TidbytAssistant integration (ver. 1.0.2)

## 1.0.1

- Added 2 new services: Publish and Text
  - Publish: Add apps to your rotation of apps
  - Text: Push custom text to your device. Supports the various available Tidbyt fonts and colors.
- Be sure to download the most up to date TidbytAssistant integration. (ver. 1.0.1)

## 1.0.0

- Initial release.
- Be sure to download the most up to date TidbytAssistant integration. (ver. 1.0.0)
