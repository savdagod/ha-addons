#!/bin/sh

# These will be sent directly from HomeAssistant
CONTENT_ID=${1:?"missing arg 1 for CONTENT_ID"} 
TB_DEVICEID=${2:?"missing arg 2 for DEVICE ID"}
TB_TOKEN=${3:?"missing arg 3 for TOKEN"}

/usr/local/bin/pixlet delete $TB_DEVICEID $CONTENT_ID --api-token $TB_TOKEN

exit 0