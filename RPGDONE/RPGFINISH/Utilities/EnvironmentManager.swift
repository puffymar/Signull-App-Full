import Foundation

class EnvironmentManager {
    static let shared = EnvironmentManager()
    
    private var environmentVariables: [String: String] = [:]
    
    private init() {
        loadEnvironmentVariables()
    }
    
    private func loadEnvironmentVariables() {
        print("[EnvironmentManager] Starting to load environment variables...")
        print("[EnvironmentManager] Current working directory: \(FileManager.default.currentDirectoryPath)")
        var loaded = false
        // Try to load from .env file in app bundle
        if let envPath = Bundle.main.path(forResource: ".env", ofType: nil) {
            print("[EnvironmentManager] Found .env file in app bundle at: \(envPath)")
            do {
                let envContent = try String(contentsOfFile: envPath, encoding: .utf8)
                print("[EnvironmentManager] Successfully loaded .env content from bundle: \(envContent)")
                parseEnvironmentFile(envContent)
                loaded = true
            } catch {
                print("⚠️ Could not load .env file from bundle: \(error)")
            }
        } else {
            print("[EnvironmentManager] .env file not found in app bundle. Trying project directory...")
            // Try to load from project directory (for dev/debug)
            let fm = FileManager.default
            let possiblePaths = ["./.env", "../.env", "RPGFINISH/.env"]
            print("[EnvironmentManager] Checking paths: \(possiblePaths)")
            for path in possiblePaths {
                print("[EnvironmentManager] Checking path: \(path)")
                if fm.fileExists(atPath: path) {
                    print("[EnvironmentManager] Found .env file in project dir at: \(path)")
                    do {
                        let envContent = try String(contentsOfFile: path, encoding: .utf8)
                        print("[EnvironmentManager] Successfully loaded .env content from project dir: \(envContent)")
                        parseEnvironmentFile(envContent)
                        loaded = true
                        break
                    } catch {
                        print("⚠️ Could not load .env file from project dir: \(error)")
                    }
                } else {
                    print("[EnvironmentManager] Path not found: \(path)")
                }
            }
        }
        if !loaded {
            print("[EnvironmentManager] ❌ .env file not found anywhere!")
        }
        
        // Fallback to process environment variables
        for (key, value) in ProcessInfo.processInfo.environment {
            environmentVariables[key] = value
        }
        
        print("[EnvironmentManager] Final environment variables: \(environmentVariables)")
    }
    
    private func parseEnvironmentFile(_ content: String) {
        let lines = content.components(separatedBy: .newlines)
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Skip empty lines and comments
            if trimmedLine.isEmpty || trimmedLine.hasPrefix("#") {
                continue
            }
            
            // Parse KEY=VALUE format
            if let equalIndex = trimmedLine.firstIndex(of: "=") {
                let key = String(trimmedLine[..<equalIndex]).trimmingCharacters(in: .whitespacesAndNewlines)
                let value = String(trimmedLine[trimmedLine.index(after: equalIndex)...]).trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Remove quotes if present
                let cleanValue = value.replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "'", with: "")
                
                environmentVariables[key] = cleanValue
            }
        }
    }
    
    func getValue(for key: String) -> String? {
        return environmentVariables[key]
    }
    
    func getValue(for key: String, defaultValue: String) -> String {
        return environmentVariables[key] ?? defaultValue
    }
    
    // MARK: - Specific API Key Access
    
    var claudeAPIKey: String? {
        // Try multiple possible key names
        let possibleKeys = ["API_KEY", "CLAUDE_API_KEY", "ANTHROPIC_API_KEY", "CLAUDE_KEY"]
        for key in possibleKeys {
            if let value = getValue(for: key), !value.isEmpty {
                print("✅ Found API key with name: \(key)")
                return value
            }
        }
        return nil
    }
    
    var claudeAPIKeyRequired: String {
        guard let key = claudeAPIKey, !key.isEmpty else {
            print("❌ Available environment variables: \(environmentVariables.keys)")
            fatalError("❌ Claude API Key not found in environment variables. Please add API_KEY=\"your_key_here\" to your .env file.")
        }
        return key
    }
    
    var openAIAPIKey: String? {
        // Try multiple possible key names for OpenAI
        let possibleKeys = ["OPENAI_API_KEY", "OPENAI_KEY", "GPT_API_KEY", "OPENAI_API"]
        for key in possibleKeys {
            if let value = getValue(for: key), !value.isEmpty {
                print("✅ Found OpenAI API key with name: \(key)")
                return value
            }
        }
        return nil
    }
    
    var openAIAPIKeyRequired: String {
        guard let key = openAIAPIKey, !key.isEmpty else {
            print("❌ Available environment variables: \(environmentVariables.keys)")
            fatalError("❌ OpenAI API Key not found in environment variables. Please add OPENAI_API_KEY=\"your_key_here\" to your .env file.")
        }
        return key
    }
    
    // MARK: - Testing and Validation
    
    func validateAPIKey() -> Bool {
        let key = claudeAPIKey
        return key != nil && !key!.isEmpty && key!.count > 20 // Basic validation
    }
    
    func validateOpenAIAPIKey() -> Bool {
        let key = openAIAPIKey
        return key != nil && !key!.isEmpty && key!.count > 20 // Basic validation
    }
    
    func printAPIKeyStatus() {
        if validateAPIKey() {
            print("✅ Claude API Key loaded successfully")
        } else {
            print("❌ Claude API Key not found or invalid")
            print("📝 Please create a .env file with: API_KEY=\"your_claude_api_key\"")
        }
        
        if validateOpenAIAPIKey() {
            print("✅ OpenAI API Key loaded successfully")
        } else {
            print("❌ OpenAI API Key not found or invalid")
            print("📝 Please create a .env file with: OPENAI_API_KEY=\"your_openai_api_key\"")
        }
    }
} 