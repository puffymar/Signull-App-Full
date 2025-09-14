import Foundation

class EnvironmentConfig: ObservableObject {
    static let shared = EnvironmentConfig()
    
    @Published var openAIAPIKey: String?
    @Published var environment: String = "development"
    @Published var apiBaseURL: String = "https://api.openai.com/v1"
    
    private init() {
        loadEnvironmentVariables()
    }
    
    private func loadEnvironmentVariables() {
        // Load from .env file if available
        if let envPath = Bundle.main.path(forResource: ".env", ofType: nil),
           let envContents = try? String(contentsOfFile: envPath) {
            parseEnvFile(envContents)
        }
        
        // Fallback to environment variables
        openAIAPIKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"]
        environment = ProcessInfo.processInfo.environment["ENVIRONMENT"] ?? "development"
        apiBaseURL = ProcessInfo.processInfo.environment["API_BASE_URL"] ?? "https://api.openai.com/v1"
        
        // For development, you can set the API key directly
        // Do not hardcode API keys in source. Use .env or environment variables only.
        
        print("🔧 Environment loaded: \(environment)")
        print("🔧 API Base URL: \(apiBaseURL)")
        print("🔧 OpenAI API Key: \(openAIAPIKey?.prefix(20) ?? "Not found")...")
    }
    
    private func parseEnvFile(_ contents: String) {
        let lines = contents.components(separatedBy: .newlines)
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty && !trimmed.hasPrefix("#") {
                let components = trimmed.components(separatedBy: "=")
                if components.count == 2 {
                    let key = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
                    let value = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    switch key {
                    case "OPENAI_API_KEY":
                        openAIAPIKey = value
                    case "ENVIRONMENT":
                        environment = value
                    case "API_BASE_URL":
                        apiBaseURL = value
                    default:
                        break
                    }
                }
            }
        }
    }
    
    func getAPIKey() -> String? {
        return openAIAPIKey
    }
    
    func isDevelopment() -> Bool {
        return environment == "development"
    }
    
    func isProduction() -> Bool {
        return environment == "production"
    }
} 