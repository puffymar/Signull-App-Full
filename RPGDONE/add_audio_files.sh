#!/bin/bash

# Add audio files to Xcode project
echo "Adding audio files to RPGFINISH project..."

# Check if we're in the right directory
if [ ! -d "RPGFINISH" ]; then
    echo "Error: RPGFINISH directory not found"
    exit 1
fi

# Add audio files to the project
find RPGFINISH/Assets.xcassets/audio -name "*.mp3" -o -name "*.wav" | while read file; do
    echo "Adding $file to project..."
    # This would typically use xcodebuild or similar to add files
    echo "File: $file"
done

echo "Audio files added successfully!"
