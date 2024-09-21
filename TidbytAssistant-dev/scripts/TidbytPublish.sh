#!/bin/sh
set -e

# These will be sent directly from HomeAssistant
CONTENT=${1:?"missing arg 1 for CONTENT"} 
TB_DEVICEID=${2:?"missing arg 2 for DEVICE ID"}
TB_TOKEN=${3:?"missing arg 3 for TOKEN"}
CONTENT_ID=${4:?"missing arg 4 for CONTENT_ID"}

ROOT_DIR=/homeassistant/tidbyt
RENDER_PATH=/tmp/render.webp

cp $ROOT_DIR/$CONTENT.star /tmp/$CONTENT.star -f
/usr/local/bin/pixlet render /tmp/$CONTENT.star -o $RENDER_PATH

/usr/local/bin/pixlet push --installation-id $CONTENT_ID --api-token $TB_TOKEN $TB_DEVICEID $RENDER_PATH
rm -r /tmp/*

exit 0
