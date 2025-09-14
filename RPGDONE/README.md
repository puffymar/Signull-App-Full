# Signull - AI-Powered Interactive Storytelling

<div align="center">
  <img src="RPGFINISH/Assets.xcassets/AppIcon.appiconset/Icon-1024.png" alt="Signull Logo" width="120" height="120">
  
  **An immersive AI-driven RPG experience that crafts personalized narratives in real-time**
  
  [![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
  [![iOS](https://img.shields.io/badge/iOS-16.0+-blue.svg)](https://developer.apple.com/ios/)
  [![Xcode](https://img.shields.io/badge/Xcode-15.0+-blue.svg)](https://developer.apple.com/xcode/)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
</div>

## 🌟 Overview

Signull is a cutting-edge iOS application that combines artificial intelligence with interactive storytelling to create deeply personalized RPG experiences. Built with SwiftUI and powered by advanced AI models, it generates dynamic narratives that adapt to player choices, creating unique stories every time.

### Key Features

- **🤖 AI-Powered Story Generation**: Real-time narrative creation using advanced language models
- **🎭 Dynamic Character Development**: Characters that evolve based on player interactions
- **🎨 Immersive Visual Design**: Custom shaders, reactive UI elements, and atmospheric effects
- **🎵 Adaptive Audio System**: Dynamic music and sound effects that respond to story mood
- **💾 Persistent Progression**: Save system that maintains story continuity across sessions
- **📱 Modern iOS Architecture**: Built with SwiftUI, Combine, and modern iOS design patterns

## 🏗️ Architecture

### Core Components

- **AI Engine** (`RPGFINISH/AI/`): Handles story generation, prompt engineering, and response parsing
- **Models** (`RPGFINISH/Models/`): Data structures for stories, characters, and game state
- **ViewModels** (`RPGFINISH/ViewModels/`): Business logic and state management
- **Views** (`RPGFINISH/Views/`): SwiftUI user interface components
- **Utilities** (`RPGFINISH/Utilities/`): Helper classes for audio, networking, and performance

### Technical Highlights

- **SwiftUI + Combine**: Reactive UI with modern state management
- **Custom Metal Shaders**: GPU-accelerated visual effects
- **Network Layer**: Robust API client with error handling and retry logic
- **Audio Engine**: Dynamic audio mixing with spatial effects
- **Performance Monitoring**: Real-time performance tracking and optimization

## 🚀 Getting Started

### Prerequisites

- Xcode 15.0 or later
- iOS 16.0 or later
- Swift 5.9 or later

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/puffymar/Signull-App-Full.git
   cd Signull-App-Full
   ```

2. Open the project in Xcode:
   ```bash
   open RPGFINISH.xcodeproj
   ```

3. Configure your API keys (see Configuration section)

4. Build and run the project

### Configuration

Create a `.env` file in the project root with your API credentials:

```env
OPENAI_API_KEY=your_openai_api_key_here
SIGNULL_API_ENDPOINT=your_api_endpoint_here
```

**Note**: Never commit API keys to version control. The `.gitignore` file is configured to exclude sensitive data.

## 🎮 Usage

### Story Generation

Signull uses advanced prompt engineering to create coherent, engaging narratives:

- **Second-person perspective**: Stories are written as if happening to the player
- **Dynamic character integration**: Player name is seamlessly woven into the narrative
- **Mood-based generation**: Stories adapt their tone based on current game state
- **Choice-driven progression**: Player decisions influence story direction

### AI Features

- **Contextual Awareness**: AI maintains story continuity and character consistency
- **Emotional Intelligence**: Responses adapt to player's emotional state
- **Creative Variety**: Advanced algorithms prevent repetitive content
- **Quality Assurance**: Built-in validation ensures coherent narrative flow

## 🛠️ Development

### Project Structure

```
RPGFINISH/
├── AI/                    # AI and story generation logic
├── Assets.xcassets/       # App icons, images, and audio
├── Config/                # Configuration and settings
├── Models/                # Data models and enums
├── Shaders/               # Metal shader files
├── Tests/                 # Unit and integration tests
├── Utilities/             # Helper classes and utilities
├── ViewModels/            # Business logic and state management
└── Views/                 # SwiftUI user interface
```

### Key Technologies

- **SwiftUI**: Modern declarative UI framework
- **Combine**: Reactive programming and data flow
- **Metal**: GPU-accelerated graphics and shaders
- **Core Data**: Local data persistence
- **AVFoundation**: Audio processing and playback
- **Network**: HTTP client and API integration

### Code Quality

- **MVVM Architecture**: Clean separation of concerns
- **Protocol-Oriented Design**: Flexible and testable code
- **Error Handling**: Comprehensive error management
- **Performance Optimization**: Efficient memory and CPU usage
- **Accessibility**: Full VoiceOver and accessibility support

## 📱 Screenshots

<div align="center">
  <img src="RPGFINISH/Assets.xcassets/First3.imageset/First3.png" alt="Game Screenshot 1" width="200">
  <img src="RPGFINISH/Assets.xcassets/Wasteland2.imageset/Wasteland2.png" alt="Game Screenshot 2" width="200">
</div>

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development Guidelines

1. Follow Swift style guidelines
2. Write comprehensive tests for new features
3. Update documentation for API changes
4. Ensure all tests pass before submitting

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- OpenAI for providing the AI models that power story generation
- Apple for the excellent SwiftUI and iOS development tools
- The Swift community for inspiration and best practices

## 📞 Contact

**Developer**: [Your Name]
- GitHub: [@puffymar](https://github.com/puffymar)
- Email: [your.email@example.com]

---

<div align="center">
  <p>Built with ❤️ using Swift and SwiftUI</p>
  <p>© 2025 Signull. All rights reserved.</p>
</div>
