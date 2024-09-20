#!/bin/sh
set -e

CONTENT=${1:?"missing arg 1 for CONTENT"} 
TB_DEVICEID=${2:?"missing arg 2 for DEVICE ID"}
TB_TOKEN=${3:?"missing arg 3 for TOKEN"}
TEXT_TYPE=${4:?"missing arg 4 for TEXT_TYPE"}
FONT=${5:?"missing arg 5 for FONT"}
COLOR=${6:?"missing arg 6 for COLOR"}

ROOT_DIR=/tmp
FILE=text-$TEXT_TYPE

cp /opt/display/$FILE.star $ROOT_DIR/$FILE.star -f
#perl -pi -e "s/%DISPLAY_TEXT%/$CONTENT/g" $ROOT_DIR/$FILE.star
#perl -pi -e "s/%DISPLAY_FONT%/$FONT/g" $ROOT_DIR/$FILE.star
#perl -pi -e "s/%DISPLAY_COLOR%/$COLOR/g" $ROOT_DIR/$FILE.star

RENDER_PATH=/tmp/render.webp

/usr/local/bin/pixlet render $ROOT_DIR/$FILE.star content="$CONTENT" font="$FONT" color="$COLOR" -o $RENDER_PATH

/usr/local/bin/pixlet push --api-token $TB_TOKEN $TB_DEVICEID $RENDER_PATH
rm -r /tmp/*

exit 0
