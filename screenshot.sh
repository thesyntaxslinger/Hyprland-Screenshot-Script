#!/bin/bash

mkdir -p "$HOME/Pictures/screenshots"

FILENAME=$(date '+%Y-%m-%d_%H-%m-%S.png')
SAVE_PATH="$HOME/Pictures/screenshots/$FILENAME"

if ! grimblast --freeze copysave area "$SAVE_PATH"; then
    notify-send "Screenshot Canceled" "No image captured"
    exit 1
fi

if [ -n "$1" ]; then
    export FILENAME=$FILENAME
    envsubst < $HOME/.config/swappy/config.var > $HOME/.config/swappy/config
    swappy -f $SAVE_PATH
fi

exiftool -overwrite_original -a -ALL:ALL= "$SAVE_PATH"

make_jpeg() {
  JPG_PATH="${SAVE_PATH%.*}.jpg"
  ffmpeg -v error -i "$SAVE_PATH" -q:v 2 "$JPG_PATH"
  exiftool -overwrite_original -a -ALL:ALL= "$JPG_PATH"
}

copy_to_clip() {
    if [[ $URL == http* ]]; then
        echo "$URL" | wl-copy
        notify-send "Upload Successful!" "URL copied to clipboard" -i "$SAVE_PATH"
    else
        notify-send "Upload Failed" "Error: $URL" -i "$SAVE_PATH"
    fi
}


CHOICE=$(echo -e "Upload temporarily to catbox.moe\nUpload permanent to catbox.moe\nKeep local only\nDelete/Cancel" | fuzzel -d)

case $CHOICE in
    *temporarily*)
        make_jpeg
        URL=$(curl -s -F "reqtype=fileupload" -F fileNameLength=16 -F time="1h" -F "fileToUpload=@$JPG_PATH" "https://litterbox.catbox.moe/resources/internals/api.php")
        copy_to_clip
        rm $JPG_PATH $SAVE_PATH
        ;;
    *permanent*)
        make_jpeg
        URL=$(curl -s -F "reqtype=fileupload" -F "fileToUpload=@$JPG_PATH" "https://catbox.moe/user/api.php")
        copy_to_clip
        rm $JPG_PATH $SAVE_PATH
        ;;
    Keep*)
        notify-send "Screenshot Saved" "Local copy created" -i "$SAVE_PATH"
        ;;
    *)
        notify-send "Screenshot Canceled" "No image captured"
        rm $SAVE_PATH
        ;;
esac
