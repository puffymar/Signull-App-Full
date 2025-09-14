import Foundation
import Combine
import UIKit

// MARK: - Performance Monitor
class PerformanceMonitor: ObservableObject {
    static let shared = PerformanceMonitor()
    
    // Performance metrics
    @Published var currentFPS: Double = 60.0
    @Published var memoryUsage: Double = 0.0
    @Published var cpuUsage: Double = 0.0
    @Published var batteryLevel: Double = 1.0
    
    // Performance thresholds
    private let lowFPSThreshold: Double = 30.0
    private let highMemoryThreshold: Double = 0.8
    private let highCPUThreshold: Double = 0.7
    private let lowBatteryThreshold: Double = 0.2
    
    // Monitoring state
    private var isMonitoring = false
    private var displayLink: CADisplayLink?
    private var frameCount = 0
    private var lastFrameTime: CFTimeInterval = 0
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    // MARK: - Monitoring Setup
    
    private func setupMonitoring() {
        // Start monitoring when app becomes active
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.startMonitoring()
            }
            .store(in: &cancellables)
        
        // Stop monitoring when app becomes inactive
        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
            .sink { [weak self] _ in
                self?.stopMonitoring()
            }
            .store(in: &cancellables)
    }
    
    func startMonitoring() {
        guard !isMonitoring else { return }
        setupMonitoring()
        isMonitoring = true
        
        // Start FPS monitoring
        displayLink = CADisplayLink(target: self, selector: #selector(updateFPS))
        displayLink?.add(to: .main, forMode: .common)
        
        // Start periodic monitoring
        Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateSystemMetrics()
            }
            .store(in: &cancellables)
    }
    
    func stopMonitoring() {
        isMonitoring = false
        displayLink?.invalidate()
        displayLink = nil
        cancellables.removeAll()
    }
    
    // MARK: - Performance Updates
    
    @objc private func updateFPS() {
        frameCount += 1
        let currentTime = CACurrentMediaTime()
        
        if currentTime - lastFrameTime >= 1.0 {
            currentFPS = Double(frameCount)
            frameCount = 0
            lastFrameTime = currentTime
            
            // Check for performance issues
            checkPerformanceIssues()
        }
    }
    
    private func updateSystemMetrics() {
        // Update memory usage
        memoryUsage = getMemoryUsage()
        
        // Update CPU usage (simplified)
        cpuUsage = getCPUUsage()
        
        // Update battery level
        batteryLevel = Double(UIDevice.current.batteryLevel)
    }
    
    private func checkPerformanceIssues() {
        var issues: [String] = []
        
        if currentFPS < lowFPSThreshold {
            issues.append("Low FPS: \(String(format: "%.1f", currentFPS))")
        }
        
        if memoryUsage > highMemoryThreshold {
            issues.append("High memory usage: \(String(format: "%.1f%%", memoryUsage * 100))")
        }
        
        if cpuUsage > highCPUThreshold {
            issues.append("High CPU usage: \(String(format: "%.1f%%", cpuUsage * 100))")
        }
        
        if batteryLevel < lowBatteryThreshold {
            issues.append("Low battery: \(String(format: "%.1f%%", batteryLevel * 100))")
        }
        
        if !issues.isEmpty {
            print("⚠️ Performance issues detected: \(issues.joined(separator: ", "))")
            triggerOptimizations()
        }
    }
    
    private func triggerOptimizations() {
        // Reduce visual effects
        NotificationCenter.default.post(name: .reduceVisualEffects, object: nil)
        
        // Clear caches if memory is high
        if memoryUsage > highMemoryThreshold {
            ContentManager.shared.clearCaches()
        }
    }
    
    // MARK: - System Metrics
    
    private func getMemoryUsage() -> Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            let usedMemory = Double(info.resident_size)
            let totalMemory = Double(ProcessInfo.processInfo.physicalMemory)
            return usedMemory / totalMemory
        }
        
        return 0.0
    }
    
    private func getCPUUsage() -> Double {
        // Simplified CPU usage calculation
        // In a real implementation, you'd use more sophisticated methods
        return Double.random(in: 0.1...0.3) // Placeholder
    }
    
    // MARK: - Performance Reports
    
    func generatePerformanceReport() -> String {
        return """
        Performance Report:
        - FPS: \(String(format: "%.1f", currentFPS))
        - Memory Usage: \(String(format: "%.1f%%", memoryUsage * 100))
        - CPU Usage: \(String(format: "%.1f%%", cpuUsage * 100))
        - Battery Level: \(String(format: "%.1f%%", batteryLevel * 100))
        """
    }
}

// MARK: - Notifications
extension Notification.Name {
    static let reduceVisualEffects = Notification.Name("reduceVisualEffects")
} 