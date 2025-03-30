#!/bin/bash

# Check if logo.png exists
if [ ! -f logo.png ]; then
    echo "logo.png not found! Please place it in the current directory."
    exit 1
fi

# Create icons directory and iconset directory
mkdir -p icons
rm -rf icons.iconset
mkdir -p icons.iconset

# Generate icons of various sizes
magick logo.png -resize 16x16 icons.iconset/icon_16x16.png
magick logo.png -resize 32x32 icons.iconset/icon_16x16@2x.png
magick logo.png -resize 32x32 icons.iconset/icon_32x32.png
magick logo.png -resize 64x64 icons.iconset/icon_32x32@2x.png
magick logo.png -resize 128x128 icons.iconset/icon_128x128.png
magick logo.png -resize 256x256 icons.iconset/icon_128x128@2x.png
magick logo.png -resize 256x256 icons.iconset/icon_256x256.png
magick logo.png -resize 512x512 icons.iconset/icon_256x256@2x.png
magick logo.png -resize 512x512 icons.iconset/icon_512x512.png
magick logo.png -resize 1024x1024 icons.iconset/icon_512x512@2x.png

# Create icns file from the iconset
iconutil -c icns icons.iconset -o AppIcon.icns

# Clean up
rm -rf icons.iconset

echo "AppIcon.icns created successfully." 