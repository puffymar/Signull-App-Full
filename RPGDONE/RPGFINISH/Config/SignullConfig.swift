import Foundation

enum SignullMode: String { 
    case fallback, live, stub
}

struct SignullConfig {
    static var mode: SignullMode = .live   // Use live API with fallback on error
    static let proxyURL = URL(string: "https://api.signullrift.com/responses")!
    static let logURL   = URL(string: "https://api.signullrift.com/log")!
    static let appToken = "signull_app_token_2024" // not an OpenAI key. Rotate monthly.
    
    // Feature flags for gradual rollout
    static var enableStreaming: Bool = true
    static var enableTelemetry: Bool = false  // Disabled due to 404 errors on telemetry endpoint
    static var enableRetry: Bool = true
    
    // Performance settings
    static let connectTimeout: TimeInterval = 20.0
    static let readTimeout: TimeInterval = 90.0
    static let maxRetries: Int = 3
    static let baseRetryDelay: TimeInterval = 0.5
    
    // Content settings
    static var reduceIntensity: Bool = false
    static let maxStoryLength: Int = 4 // paragraphs
    static let maxChoiceLength: Int = 120 // characters
    
    // Debug settings
    static var enableDebugLogging: Bool = true
    static var mockAPIResponses: Bool = false
    
    // API priority settings
    static var forceLiveMode: Bool = true  // Always try live API first
    static var fallbackOnlyOnError: Bool = true  // Only use fallback on actual errors
    
    // MARK: - Configuration Helpers
    
    static func isLiveMode() -> Bool {
        return mode == .live && forceLiveMode
    }
    
    static func isStubMode() -> Bool {
        return mode == .stub
    }
    
    static func shouldUseFallback() -> Bool {
        return mode == .fallback || !enableStreaming
    }
    
    static func shouldRetryOnError() -> Bool {
        return fallbackOnlyOnError && enableRetry
    }
    
    static func getStoryPromptModifier() -> String {
        if reduceIntensity {
            return " Tone down graphic content and keep descriptions mild."
        }
        return ""
    }
    
    static func getMaxTokens() -> Int {
        if reduceIntensity {
            return 800 // Shorter stories for reduced intensity
        }
        return 1200 // Full length stories
    }
    
    // MARK: - Validation
    
    static func validateConfiguration() -> Bool {
        guard let _ = URL(string: "https://api.openai.com/v1") else {
            print("🔍 DEBUG: Invalid OpenAI API URL")
            return false
        }
        
        if mode == .live {
            guard !appToken.isEmpty else {
                print("🔍 DEBUG: App token is empty")
                return false
            }
        }
        
        return true
    }
    
    // MARK: - Runtime Configuration
    
    static func switchToLiveMode() {
        mode = .live
        print("🔍 DEBUG: Switched to live mode")
    }
    
    static func switchToFallbackMode() {
        mode = .fallback
        print("🔍 DEBUG: Switched to fallback mode")
    }
    
    static func switchToStubMode() {
        mode = .stub
        print("🔍 DEBUG: Switched to stub mode")
    }
    
    static func toggleIntensity() {
        reduceIntensity.toggle()
        print("🔍 DEBUG: Intensity reduced: \(reduceIntensity)")
    }
} 