#!/bin/bash

# Create icons first
./create_icons.sh

# Create a temporary directory for DMG contents
rm -rf SimpleApp TempDMG
mkdir -p SimpleApp TempDMG

# Copy the Swift file and Info.plist
cp NetworkSpeedMonitor.swift SimpleApp/
cp Info.plist SimpleApp/

# Compile the app
cd SimpleApp
swiftc NetworkSpeedMonitor.swift -o "Network Speed"
mkdir -p "Network Speed.app/Contents/MacOS"
mkdir -p "Network Speed.app/Contents/Resources"

# Move the binary and add Info.plist
mv "Network Speed" "Network Speed.app/Contents/MacOS/"
cp ../Info.plist "Network Speed.app/Contents/"
cp ../AppIcon.icns "Network Speed.app/Contents/Resources/"

cd ..

# Create a temporary DMG
rm -f "Network Speed.dmg" temp.dmg
hdiutil create -size 100m -fs HFS+ -volname "Network Speed" temp.dmg

# Mount the DMG
hdiutil attach temp.dmg -mountpoint TempDMG

# Copy the app to the DMG
cp -r "SimpleApp/Network Speed.app" TempDMG/

# Create Applications shortcut
ln -s /Applications TempDMG/Applications

# Set custom icon for the volume (optional)
cp AppIcon.icns TempDMG/.VolumeIcon.icns
SetFile -a C TempDMG

# Unmount the DMG
hdiutil detach TempDMG

# Convert the DMG to compressed format
hdiutil convert temp.dmg -format UDZO -o "Network Speed.dmg"

# Clean up
rm -f temp.dmg
rm -rf SimpleApp TempDMG

echo "DMG created: Network Speed.dmg" 