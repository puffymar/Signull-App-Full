#!/bin/bash

# App Icon Generator Script
# Place your 1024x1024 icon as Icon-1024.png in the AppIcon.appiconset folder
# Then run this script to generate all required sizes

echo "Generating iOS App Icons..."

# iPhone Icons
sips -z 40 40 Icon-1024.png --out Icon-20@2x.png
sips -z 60 60 Icon-1024.png --out Icon-20@3x.png
sips -z 58 58 Icon-1024.png --out Icon-29@2x.png
sips -z 87 87 Icon-1024.png --out Icon-29@3x.png
sips -z 80 80 Icon-1024.png --out Icon-40@2x.png
sips -z 120 120 Icon-1024.png --out Icon-40@3x.png
sips -z 120 120 Icon-1024.png --out Icon-60@2x.png
sips -z 180 180 Icon-1024.png --out Icon-60@3x.png

# iPad Icons
sips -z 20 20 Icon-1024.png --out Icon-20.png
sips -z 29 29 Icon-1024.png --out Icon-29.png
sips -z 40 40 Icon-1024.png --out Icon-40.png
sips -z 76 76 Icon-1024.png --out Icon-76.png
sips -z 152 152 Icon-1024.png --out Icon-76@2x.png
sips -z 167 167 Icon-1024.png --out Icon-83.5@2x.png

echo "All app icons generated successfully!"
echo "Make sure Icon-1024.png is your main app icon image." 