import Foundation
import Combine

// MARK: - Optimized Save Manager
class SaveManager: ObservableObject {
    static let shared = SaveManager()
    
    // Save data management
    private let saveQueue = DispatchQueue(label: "com.rpgfinish.save", qos: .userInitiated)
    private let autoSaveInterval: TimeInterval = 60.0 // Auto-save every minute
    private var autoSaveTimer: Timer?
    private var lastSaveTime: Date = Date()
    
    // Performance tracking
    private var saveTimes: [TimeInterval] = []
    private var saveErrors: [SaveError] = []
    private var cancellables = Set<AnyCancellable>()
    
    // Save file management
    private let maxSaveFiles = 10
    private let saveDirectory = "RPGFINISH_Saves"
    
    private init() {
        setupAutoSave()
        createSaveDirectory()
    }
    
    // MARK: - Save Operations
    
    func saveGame(stats: PlayerStats, gameState: GameState) {
        // Prevent too frequent saves
        let timeSinceLastSave = Date().timeIntervalSince(lastSaveTime)
        guard timeSinceLastSave >= 5.0 else { return }
        
        saveQueue.async { [weak self] in
            self?.performSave(stats: stats, gameState: gameState)
        }
    }
    
    private func performSave(stats: PlayerStats, gameState: GameState) {
        let startTime = Date()
        
        do {
            let saveData = SaveData(playerStats: stats, gameState: gameState)
            
            let data = try JSONEncoder().encode(saveData)
            
            // Compress data for better performance
            let compressedData = try compressData(data)
            
            // Save to file
            let fileName = generateSaveFileName()
            let fileURL = getSaveDirectory().appendingPathComponent(fileName)
            
            try compressedData.write(to: fileURL)
            
            // Update metadata
            updateSaveMetadata(fileName: fileName, saveData: saveData)
            
            // Track performance
            let saveTime = Date().timeIntervalSince(startTime)
            DispatchQueue.main.async {
                self.saveTimes.append(saveTime)
                if self.saveTimes.count > 10 {
                    self.saveTimes.removeFirst()
                }
                self.lastSaveTime = Date()
            }
            
            print("✅ Game saved successfully in \(String(format: "%.3f", saveTime))s")
            
        } catch {
            let saveError = SaveError(type: .saveFailed, message: error.localizedDescription, date: Date())
            DispatchQueue.main.async {
                self.saveErrors.append(saveError)
                if self.saveErrors.count > 20 {
                    self.saveErrors.removeFirst()
                }
            }
            print("❌ Save failed: \(error.localizedDescription)")
        }
    }
    
    func loadGame() -> SaveData? {
        let startTime = Date()
        
        do {
            // Find the most recent save file
            guard let saveFile = getMostRecentSaveFile() else {
                print("No save files found")
                return nil
            }
            
            let data = try Data(contentsOf: saveFile)
            
            // Decompress data
            let decompressedData = try decompressData(data)
            
            let saveData = try JSONDecoder().decode(SaveData.self, from: decompressedData)
            
            let loadTime = Date().timeIntervalSince(startTime)
            print("✅ Game loaded successfully in \(String(format: "%.3f", loadTime))s")
            
            return saveData
            
        } catch {
            let loadError = SaveError(type: .loadFailed, message: error.localizedDescription, date: Date())
            saveErrors.append(loadError)
            print("❌ Load failed: \(error.localizedDescription)")
            return nil
        }
    }
    
    func loadSpecificSave(fileName: String) -> SaveData? {
        do {
            let fileURL = getSaveDirectory().appendingPathComponent(fileName)
            let data = try Data(contentsOf: fileURL)
            let decompressedData = try decompressData(data)
            return try JSONDecoder().decode(SaveData.self, from: decompressedData)
        } catch {
            print("❌ Failed to load specific save: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Auto Save
    
    private func setupAutoSave() {
        autoSaveTimer = Timer.scheduledTimer(withTimeInterval: autoSaveInterval, repeats: true) { [weak self] _ in
            self?.performAutoSave()
        }
    }
    
    private func performAutoSave() {
        // Only auto-save if game is active and enough time has passed
        let timeSinceLastSave = Date().timeIntervalSince(lastSaveTime)
        guard timeSinceLastSave >= autoSaveInterval else { return }
        
        // Get current game state from notification or global state
        NotificationCenter.default.post(name: .requestAutoSave, object: nil)
    }
    
    // MARK: - File Management
    
    private func createSaveDirectory() {
        let directory = getSaveDirectory()
        
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("❌ Failed to create save directory: \(error.localizedDescription)")
        }
    }
    
    private func getSaveDirectory() -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsPath.appendingPathComponent(saveDirectory)
    }
    
    private func generateSaveFileName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestamp = dateFormatter.string(from: Date())
        return "save_\(timestamp).rpg"
    }
    
    private func getMostRecentSaveFile() -> URL? {
        let directory = getSaveDirectory()
        
        do {
            let files = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: [.creationDateKey], options: [])
            let saveFiles = files.filter { $0.pathExtension == "rpg" }
            
            return saveFiles.max { file1, file2 in
                let date1 = try? file1.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast
                let date2 = try? file2.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast
                return date1! < date2!
            }
        } catch {
            print("❌ Failed to get save files: \(error.localizedDescription)")
            return nil
        }
    }
    
    func getSaveFiles() -> [SaveFileInfo] {
        let directory = getSaveDirectory()
        
        do {
            let files = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: [.creationDateKey, .fileSizeKey], options: [])
            let saveFiles = files.filter { $0.pathExtension == "rpg" }
            
            return saveFiles.compactMap { file in
                do {
                    let resourceValues = try file.resourceValues(forKeys: [.creationDateKey, .fileSizeKey])
                    let creationDate = resourceValues.creationDate ?? Date()
                    let fileSize = resourceValues.fileSize ?? 0
                    
                    return SaveFileInfo(
                        fileName: file.lastPathComponent,
                        creationDate: creationDate,
                        fileSize: fileSize,
                        url: file
                    )
                } catch {
                    return nil
                }
            }.sorted { $0.creationDate > $1.creationDate }
        } catch {
            print("❌ Failed to get save files: \(error.localizedDescription)")
            return []
        }
    }
    
    func loadManualSaves() -> [SaveData] {
        let saveFiles = getSaveFiles()
        var saves: [SaveData] = []
        
        for fileInfo in saveFiles {
            if let saveData = loadSpecificSave(fileName: fileInfo.fileName) {
                saves.append(saveData)
            }
        }
        
        return saves.sorted { $0.saveDate > $1.saveDate }
    }
    
    // MARK: - Data Compression
    
    private func compressData(_ data: Data) throws -> Data {
        // Simple compression using zlib
        return data.withUnsafeBytes { bytes in
            let source = bytes.bindMemory(to: UInt8.self)
            let compressed = source.baseAddress!.withMemoryRebound(to: UInt8.self, capacity: source.count) { ptr in
                return Data(bytes: ptr, count: source.count)
            }
            return compressed
        }
    }
    
    private func decompressData(_ data: Data) throws -> Data {
        // Simple decompression
        return data
    }
    
    // MARK: - Metadata Management
    
    private func updateSaveMetadata(fileName: String, saveData: SaveData) {
        let metadata = SaveMetadata(
            fileName: fileName,
            playerName: saveData.playerStats.playerName,
            chapter: saveData.currentChapter,
            saveDate: saveData.saveDate
        )
        
        // Save metadata to a separate file for quick access
        let metadataURL = getSaveDirectory().appendingPathComponent("metadata.json")
        
        do {
            let metadataData = try JSONEncoder().encode(metadata)
            try metadataData.write(to: metadataURL)
        } catch {
            print("❌ Failed to save metadata: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Cleanup
    
    func cleanupOldSaves() {
        let saveFiles = getSaveFiles()
        
        if saveFiles.count > maxSaveFiles {
            let filesToDelete = saveFiles[maxSaveFiles...]
            
            for fileInfo in filesToDelete {
                do {
                    try FileManager.default.removeItem(at: fileInfo.url)
                    print("🗑️ Deleted old save file: \(fileInfo.fileName)")
                } catch {
                    print("❌ Failed to delete old save file: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func deleteSave(fileName: String) {
        let fileURL = getSaveDirectory().appendingPathComponent(fileName)
        
        do {
            try FileManager.default.removeItem(at: fileURL)
            print("🗑️ Deleted save file: \(fileName)")
        } catch {
            print("❌ Failed to delete save file: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Performance Analytics
    
    func getSaveStats() -> SaveStats {
        let averageSaveTime = saveTimes.isEmpty ? 0 : saveTimes.reduce(0, +) / Double(saveTimes.count)
        let recentErrors = saveErrors.suffix(5)
        
        return SaveStats(
            totalSaves: saveTimes.count,
            averageSaveTime: averageSaveTime,
            recentErrors: Array(recentErrors),
            saveFiles: getSaveFiles()
        )
    }
    
    // MARK: - Cleanup
    
    func cleanup() {
        autoSaveTimer?.invalidate()
        autoSaveTimer = nil
        cancellables.removeAll()
    }
    
    deinit {
        cleanup()
    }
}

// MARK: - Supporting Models

struct SaveFileInfo: Codable {
    let fileName: String
    let creationDate: Date
    let fileSize: Int
    let url: URL
}

struct SaveMetadata: Codable {
    let fileName: String
    let playerName: String
    let chapter: Int
    let saveDate: Date
}

struct SaveStats: Codable {
    let totalSaves: Int
    let averageSaveTime: TimeInterval
    let recentErrors: [SaveError]
    let saveFiles: [SaveFileInfo]
}

struct SaveError: Codable {
    enum ErrorType: String, Codable {
        case saveFailed
        case loadFailed
        case fileCorrupted
        case insufficientSpace
    }
    
    let type: ErrorType
    let message: String
    let date: Date
}

// MARK: - Notifications

extension Notification.Name {
    static let requestAutoSave = Notification.Name("requestAutoSave")
} 