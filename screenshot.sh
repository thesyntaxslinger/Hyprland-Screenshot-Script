#!/bin/bash

mkdir -p "$HOME/Pictures/screenshots"

FILENAME=$(date '+%Y-%m-%d_%H-%m-%s.png')
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
wl-copy < "$SAVE_PATH"

JPG_PATH="${SAVE_PATH%.*}.jpg"
ffmpeg -v error -i "$SAVE_PATH" -q:v 2 "$JPG_PATH"
exiftool -overwrite_original -a -ALL:ALL= "$JPG_PATH"

copy_to_clip() {
    if [[ $URL == http* ]]; then
        echo "$URL" | wl-copy
        notify-send "Upload Successful!" "URL copied to clipboard" -i "$SAVE_PATH"
    else
        notify-send "Upload Failed" "Error: $URL" -i "$SAVE_PATH"
    fi
}


CHOICE=$(echo -e "1. Upload to temporarily to catbox.moe\n2. Upload to permanent to catbox.moe\n3. Keep local only\n4. Delete/Cancel" | fuzzel -d -p "Screenshot Action:" | awk '{print $1}')

case $CHOICE in
    "1.")

        URL=$(curl -s -F "reqtype=fileupload" -F fileNameLength=16 -F time="1h" -F "fileToUpload=@$JPG_PATH" "https://litterbox.catbox.moe/resources/internals/api.php")

        copy_to_clip

        rm $JPG_PATH $SAVE_PATH

        ;;
    "2.")

        URL=$(curl -s -F "reqtype=fileupload" -F "fileToUpload=@$JPG_PATH" "https://catbox.moe/user/api.php")
       
        copy_to_clip

        rm $JPG_PATH $SAVE_PATH

        ;;
    "3.")
        notify-send "Screenshot Saved" "Local copy created" -i "$SAVE_PATH"

        rm $JPG_PATH

        ;;
    *)
        # this was made as 4. in the menu so you can also just press escape in fuzzel and cancel that way like when using "grimblast" above
        notify-send "Screenshot Canceled" "No image captured"
        rm $JPG_PATH $SAVE_PATH

        ;;
esac

