#!/bin/sh

# These will be sent directly from HomeAssistant
CONTENT=${1:?"missing arg 1 for CONTENT"} 
TB_DEVICEID=${2:?"missing arg 2 for DEVICE ID"}
TB_TOKEN=${3:?"missing arg 3 for TOKEN"}
CONTENT_TYPE=${4:?"missing arg 4 for CONTENT_TYPE"}

case "$CONTENT_TYPE" in
	"builtin") 
		ROOT_DIR=/opt/display ;;
	"custom")
		ROOT_DIR=/homeassistant/tidbyt ;;
	"text")
		cp /opt/display/text.star /tmp/text.star -f
		perl -pi -e "s/%DISPLAY_TEXT%/$CONTENT/g" /tmp/text.star
		ROOT_DIR=/tmp
		CONTENT=text 
		;;
esac

RENDER_PATH=/tmp/render.webp

pixlet render $ROOT_DIR/$CONTENT.star -o $RENDER_PATH

pixlet push --api-token $TB_TOKEN $TB_DEVICEID $RENDER_PATH

exit 0