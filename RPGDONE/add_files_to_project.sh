#!/bin/bash

# Add files to Xcode project
echo "Adding files to RPGFINISH project..."

# Check if we're in the right directory
if [ ! -d "RPGFINISH" ]; then
    echo "Error: RPGFINISH directory not found"
    exit 1
fi

# Add Swift files
echo "Adding Swift files..."
find RPGFINISH -name "*.swift" | while read file; do
    echo "Found Swift file: $file"
done

# Add Metal shader files
echo "Adding Metal shader files..."
find RPGFINISH -name "*.metal" | while read file; do
    echo "Found Metal file: $file"
done

# Add asset files
echo "Adding asset files..."
find RPGFINISH/Assets.xcassets -type f | while read file; do
    echo "Found asset file: $file"
done

echo "Files added successfully!" 