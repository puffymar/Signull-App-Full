#!/bin/bash

# Add missing files to the Xcode project
echo "Adding missing files to RPGFINISH.xcodeproj..."

# Add IntroView.swift
xcodebuild -project RPGFINISH.xcodeproj -target RPGFINISH -add-file RPGFINISH/Views/IntroView.swift

# Add AIStoriesScreen.swift
xcodebuild -project RPGFINISH.xcodeproj -target RPGFINISH -add-file RPGFINISH/Views/AIStoriesScreen.swift

# Add AppMode.swift
xcodebuild -project RPGFINISH.xcodeproj -target RPGFINISH -add-file RPGFINISH/Models/AppMode.swift

# Add EnvironmentManager.swift
xcodebuild -project RPGFINISH.xcodeproj -target RPGFINISH -add-file RPGFINISH/Utilities/EnvironmentManager.swift

# Add PromptEngine.swift
xcodebuild -project RPGFINISH.xcodeproj -target RPGFINISH -add-file RPGFINISH/Utilities/PromptEngine.swift

# Add CreateStoryView.swift
xcodebuild -project RPGFINISH.xcodeproj -target RPGFINISH -add-file RPGFINISH/Views/CreateStoryView.swift

# Add CommunityView.swift
xcodebuild -project RPGFINISH.xcodeproj -target RPGFINISH -add-file RPGFINISH/Views/CommunityView.swift

# Add ColorExtensions.swift
xcodebuild -project RPGFINISH.xcodeproj -target RPGFINISH -add-file RPGFINISH/Utilities/ColorExtensions.swift

# Add GPTEngine.swift
xcodebuild -project RPGFINISH.xcodeproj -target RPGFINISH -add-file RPGFINISH/Utilities/GPTEngine.swift

# Add NarrativeAudioManager.swift
xcodebuild -project RPGFINISH.xcodeproj -target RPGFINISH -add-file RPGFINISH/Utilities/NarrativeAudioManager.swift

# Add ContextTracker.swift
xcodebuild -project RPGFINISH.xcodeproj -target RPGFINISH -add-file RPGFINISH/Utilities/ContextTracker.swift

echo "Files added successfully!" 