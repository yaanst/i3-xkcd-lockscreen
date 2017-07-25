#!/bin/bash -x

URL="https://xkcd.com"
IMG_URL="https://imgs.xkcd.com/comics"
IMG_DIR="/home/.../Pictures/lockscreen"

#Get latest already downloaded comic's name 
CURRENT_IMG=`ls -t $IMG_DIR | head -n 1`
LATEST_IMG=""

# Check if we have internet connection
nc -z 8.8.8.8 53 2>&1 >/dev/null
CON=$?

if [ $CON -eq 0 ]; then
    # If Yes, get the latest available comic's name
    LATEST_IMG=`curl -k $URL 2>/dev/null | perl -n -e '/https:\/\/.*\/comics\/(.+).png/ && print $1'`
else
    LATEST_IMG=$CURRENT_IMG
fi

# Take screen shot and pixelize it
scrot /tmp/screen.png
convert /tmp/screen.png -scale 10% -scale 1000% /tmp/screen.png

# Download comic if not already in library
if [ ! "$LATEST_IMG" == "$CURRENT_IMG" ]; then
    wget -O $IMG_DIR/$LATEST_IMG $IMG_URL/$LATEST_IMG.png
    # Make the comic bigger
    convert $IMG_DIR/$LATEST_IMG -scale 110% -scale 110% $IMG_DIR/$LATEST_IMG
    RANDM_IMG=$LATEST_IMG
else
    # If no new comic, select a random one from library
    RANDM_IMG=`ls --hide=README $IMG_DIR | sort -R | head -n 1`
fi

# Add the chosen comic over the pixelized background and lock the sreen using the final image
[[ -f $IMG_DIR/$RANDM_IMG ]] && convert /tmp/screen.png $IMG_DIR/$RANDM_IMG -gravity center -composite -matte /tmp/screen.png
i3lock -i /tmp/screen.png
