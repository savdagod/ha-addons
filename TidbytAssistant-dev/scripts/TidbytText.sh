#!/bin/sh
set -e

CONTENT=${1:?"missing arg 1 for CONTENT"} 
TB_DEVICEID=${2:?"missing arg 2 for DEVICE ID"}
TB_TOKEN=${3:?"missing arg 3 for TOKEN"}
TEXT_TYPE=${4:?"missing arg 4 for TEXT_TYPE"}
FONT=${5:?"missing arg 5 for FONT"}
COLOR=${6:?"missing arg 6 for COLOR"}
TITLE=${7:-}
TITLE_COLOR=${8:-}
TITLE_FONT=${9:-}

ROOT_DIR=/tmp
FILE=text-$TEXT_TYPE

cp /opt/display/$FILE.star $ROOT_DIR/$FILE.star -f

RENDER_PATH=/tmp/render.webp

if [[ "$TEXT_TYPE" == "title" ]]; then
	/usr/local/bin/pixlet render $ROOT_DIR/$FILE.star content="$CONTENT" font="$FONT" color="$COLOR" title="$TITLE" titlecolor="$TITLE_COLOR" titlefont="$TITLE_FONT" -o $RENDER_PATH
else
	/usr/local/bin/pixlet render $ROOT_DIR/$FILE.star content="$CONTENT" font="$FONT" color="$COLOR" -o $RENDER_PATH
fi 

/usr/local/bin/pixlet push --api-token $TB_TOKEN $TB_DEVICEID $RENDER_PATH
rm -r /tmp/*

exit 0
