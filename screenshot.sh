#!/bin/bash

mkdir -p "$HOME/Pictures/screenshots"

FILENAME=$(date '+%Y-%m-%d_%H-%m-%s_grim.png')
SAVE_PATH="$HOME/Pictures/screenshots/$FILENAME"

if ! grimblast --freeze copysave area "$SAVE_PATH"; then
    notify-send "Screenshot Canceled" "No image captured"
    exit 1
fi

exiftool -overwrite_original -a -ALL:ALL= "$SAVE_PATH"
wl-copy < "$SAVE_PATH"

CHOICE=$(echo -e "1. Upload to image host\n2. Keep local only" | fuzzel -d -p "Screenshot Action:" | awk '{print $1}')

case $CHOICE in
    "1.")
        JPG_PATH="${SAVE_PATH%.*}.jpg"
        ffmpeg -v error -i "$SAVE_PATH" -q:v 2 "$JPG_PATH"
        exiftool -overwrite_original -a -ALL:ALL= "$JPG_PATH"
        
        URL=$(curl -s -F "reqtype=fileupload" -F time="12h" -F "fileToUpload=@$JPG_PATH" "https://litterbox.catbox.moe/resources/internals/api.php")
        
        rm "$JPG_PATH"
        
        if [[ $URL == http* ]]; then
            echo "$URL" | wl-copy
            notify-send "Upload Successful!" "URL copied to clipboard" -i "$SAVE_PATH"
        else
            notify-send "Upload Failed" "Error: $URL" -i "$SAVE_PATH"
        fi
        ;;
    *)
        notify-send "Screenshot Saved" "Local copy created" -i "$SAVE_PATH"
        ;;
esac
