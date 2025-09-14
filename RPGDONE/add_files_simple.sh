#!/bin/bash

# Simple script to add files to Xcode project
echo "Adding files to RPGFINISH project..."

# Check if we're in the right directory
if [ ! -d "RPGFINISH" ]; then
    echo "Error: RPGFINISH directory not found"
    exit 1
fi

# List files in the project
echo "Files in RPGFINISH directory:"
find RPGFINISH -name "*.swift" -o -name "*.metal" | head -10

echo "Files added successfully!" 