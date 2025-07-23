# Hyprland Screenshot Script
This is just my personal screenshot script I'm currently using to screenshot things in Hyprland.
It supports temporary image uploads to catbox.moe and permanent ones.

## Features
- Conversion to jpeg for image hosts to save bandwidth/space/load times for people viewing your images
- Wiping of exif data with `exiftool` for privacy
- Option to edit files to remove sensitive data before you upload them to the image hosts
- Option to keep local only
- Exit options to cancel and not take any screenshots
- Notifications to your Wayland notification manager

## Installation
You will need a few bash utilities for the script to work, plus an AUR package.
```bash
yay -Sy grimblast-git
sudo pacman -Sy exiftool ffmpeg swappy fuzzel
```
I know ffmpeg is bloated for this script, but I already have it installed and don't see a reason to change it right now.

You will also need to grab the source and put it somewhere, as well as place the swappy config in your .config folder.
```bash
git clone https://github.com/thesyntaxslinger/Hyprland-Screenshot-Script
cd Hyprland-Screenshot-Script
mkdir -p $HOME/myscripts
mv screenshot.sh $HOME/myscripts
mv .config/swappy $HOME/.config/swappy
cd ..
rm -rf Hyprland-Screenshot-Script
```


## Usage
There are 2 modes for this script.
- One that will just screenshot
- One that will just screenshot + also allow you to edit the photo/draw over sensitive information

```bash
./screenshot.sh
./screenshot.sh with-edit
```

The best way to do this is probably to bind them to your window manager for the print screen button, then another one with a modifier key and the print screen button to edit the screenshot.

```conf
bind = , print, exec, $HOME/myscripts/screenshot.sh
bind = $mainMod, print, exec, $HOME/myscripts/screenshot.sh with-edit
```

## Issues
Please open any issues for any feature requests or problems with the script.
