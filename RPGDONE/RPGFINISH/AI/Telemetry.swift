import Foundation

struct TelemetryEvent {
    let name: String
    let timestamp: Date
    let payload: [String: Any]
    
    init(_ name: String, _ payload: [String: Any] = [:]) {
        self.name = name
        self.timestamp = Date()
        self.payload = payload
    }
}

class Telemetry {
    static let shared = Telemetry()
    private init() {}
    
    // MARK: - Event Logging
    
    func logEvent(_ name: String, _ payload: [String: Any] = [:]) {
        guard SignullConfig.enableTelemetry else { return }
        
        let event = TelemetryEvent(name, payload)
        
        // Local logging for debugging
        if SignullConfig.enableDebugLogging {
            print("🔍 TELEMETRY: \(event.name) - \(event.payload)")
        }
        
        // Send to remote if in live mode
        if SignullConfig.isLiveMode() {
            Task.detached {
                await self.sendToRemote(event)
            }
        }
    }
    
    // Alias for capture method used in SignullAPI
    func capture(event: String, props: [String: Any] = [:]) {
        logEvent(event, props)
    }
    
    // MARK: - Specific Event Types
    
    func logScreenView(_ screenName: String) {
        logEvent("screen_view", ["screen": screenName])
    }
    
    func logStoryGenerationStart() {
        logEvent("story_generation_start", [
            "mode": SignullConfig.mode.rawValue,
            "intensity_reduced": SignullConfig.reduceIntensity
        ])
    }
    
    func logStoryGenerationComplete(latencyMs: Int, storyTitle: String) {
        logEvent("story_generation_complete", [
            "latency_ms": latencyMs,
            "mode": SignullConfig.mode.rawValue,
            "story_title": storyTitle,
            "intensity_reduced": SignullConfig.reduceIntensity
        ])
    }
    
    func logStoryGenerationError(_ error: Error, latencyMs: Int? = nil) {
        var payload: [String: Any] = [
            "error": String(describing: error),
            "mode": SignullConfig.mode.rawValue
        ]
        
        if let latencyMs = latencyMs {
            payload["latency_ms"] = latencyMs
        }
        
        logEvent("story_generation_error", payload)
    }
    
    func logDreamButtonTap() {
        logEvent("dream_button_tap", [
            "mode": SignullConfig.mode.rawValue
        ])
    }
    
    func logChoiceSelected(choiceId: String, storyTitle: String) {
        logEvent("choice_selected", [
            "choice_id": choiceId,
            "story_title": storyTitle
        ])
    }
    
    func logSceneCompleted(storyTitle: String, durationMs: Int) {
        logEvent("scene_completed", [
            "story_title": storyTitle,
            "duration_ms": durationMs
        ])
    }
    
    func logAppLaunch() {
        logEvent("app_launch", [
            "version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown",
            "mode": SignullConfig.mode.rawValue
        ])
    }
    
    func logPerformanceMetric(_ metric: String, value: Double, unit: String = "ms") {
        logEvent("performance_metric", [
            "metric": metric,
            "value": value,
            "unit": unit
        ])
    }
    
    // MARK: - Remote Sending
    
    private func sendToRemote(_ event: TelemetryEvent) async {
        guard SignullConfig.isLiveMode() else { return }
        
        do {
            var request = URLRequest(url: SignullConfig.logURL)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(SignullConfig.appToken, forHTTPHeaderField: "x-signull-auth")
            
            let body: [String: Any] = [
                "name": event.name,
                "ts": Int(event.timestamp.timeIntervalSince1970),
                "payload": event.payload
            ]
            
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    print("🔍 TELEMETRY ERROR: Failed to send event \(event.name) - Status: \(httpResponse.statusCode)")
                }
            }
        } catch {
            print("🔍 TELEMETRY ERROR: Failed to send event \(event.name) - \(error)")
        }
    }
    
    // MARK: - Batch Processing (for offline scenarios)
    
    private var pendingEvents: [TelemetryEvent] = []
    
    func queueEvent(_ event: TelemetryEvent) {
        pendingEvents.append(event)
        
        // If we have too many pending events, send them in batch
        if pendingEvents.count >= 10 {
            Task.detached {
                await self.flushPendingEvents()
            }
        }
    }
    
    private func flushPendingEvents() async {
        guard !pendingEvents.isEmpty else { return }
        
        let eventsToSend = pendingEvents
        pendingEvents.removeAll()
        
        for event in eventsToSend {
            await sendToRemote(event)
        }
    }
}

// MARK: - Convenience Extensions

extension Telemetry {
    static func log(_ name: String, _ payload: [String: Any] = [:]) {
        shared.logEvent(name, payload)
    }
    
    static func logScreen(_ screenName: String) {
        shared.logScreenView(screenName)
    }
    
    static func logStoryStart() {
        shared.logStoryGenerationStart()
    }
    
    static func logStoryComplete(latencyMs: Int, storyTitle: String) {
        shared.logStoryGenerationComplete(latencyMs: latencyMs, storyTitle: storyTitle)
    }
    
    static func logStoryError(_ error: Error, latencyMs: Int? = nil) {
        shared.logStoryGenerationError(error, latencyMs: latencyMs)
    }
    
    static func logDreamTap() {
        shared.logDreamButtonTap()
    }
    
    static func logChoice(_ choiceId: String, storyTitle: String) {
        shared.logChoiceSelected(choiceId: choiceId, storyTitle: storyTitle)
    }
    
    static func logSceneComplete(_ storyTitle: String, durationMs: Int) {
        shared.logSceneCompleted(storyTitle: storyTitle, durationMs: durationMs)
    }
    
    static func logLaunch() {
        shared.logAppLaunch()
    }
    
    static func logPerformance(_ metric: String, value: Double, unit: String = "ms") {
        shared.logPerformanceMetric(metric, value: value, unit: unit)
    }
} 