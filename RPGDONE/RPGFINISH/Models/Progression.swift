import Foundation
import SwiftUI

final class Progression: ObservableObject {
    static let shared = Progression()
    
    @Published var gems: Int = UserDefaults.standard.integer(forKey: "gems") {
        didSet { UserDefaults.standard.set(gems, forKey: "gems") }
    }
    
    @Published var streakDays: Int = UserDefaults.standard.integer(forKey: "streakDays") {
        didSet { UserDefaults.standard.set(streakDays, forKey: "streakDays") }
    }
    
    @Published var lastClaimDate: String = UserDefaults.standard.string(forKey: "lastClaimDate") ?? "" {
        didSet { UserDefaults.standard.set(lastClaimDate, forKey: "lastClaimDate") }
    }
    
    @Published var showDailyReward: Bool = false

    func dailyClaimIfNeeded() {
        let today = ISO8601DateFormatter().string(from: Calendar.current.startOfDay(for: Date()))
        if today != lastClaimDate {
            let wasStreakBroken = !lastClaimDate.isEmpty && !isConsecutiveDay(today: today, last: lastClaimDate)
            streakDays = wasStreakBroken ? 1 : streakDays + 1
            let reward = min(5 + streakDays, 20) // small ramp: 6, 7, 8... up to 20
            gems += reward
            lastClaimDate = today
            showDailyReward = true
            
            print("🎁 Daily claim: +\(reward) gems, streak: \(streakDays) days")
        }
    }
    
    func spend(_ amount: Int) -> Bool {
        guard gems >= amount else { return false }
        gems -= amount
        return true
    }
    
    func canReroll() -> Bool {
        return gems >= 10
    }
    
    private func isConsecutiveDay(today: String, last: String) -> Bool {
        let formatter = ISO8601DateFormatter()
        guard let todayDate = formatter.date(from: today),
              let lastDate = formatter.date(from: last) else { return false }
        
        let daysBetween = Calendar.current.dateComponents([.day], from: lastDate, to: todayDate).day ?? 0
        return daysBetween == 1
    }
} 