import SwiftUI

struct AchievementTrophyView: View {
    @StateObject private var achievementManager = AchievementManager.shared
    @State private var showingAchievements = false
    @State private var trophyRotation: Double = 0
    
    var body: some View {
        Button(action: {
            showingAchievements.toggle()
            HapticManager.shared.impact(.light)
        }) {
            ZStack {
                // Trophy background
                Circle()
                    .fill(Color.yellow.opacity(0.2))
                    .frame(width: 36, height: 36)
                
                // Trophy icon
                Image(systemName: "trophy.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.yellow)
                    .rotationEffect(.degrees(trophyRotation))
                
                // Achievement count badge - only show when notifications are enabled
                if achievementManager.getUnlockedCount() > 0 && achievementManager.notificationSetting > 0 {
                    Text("\(achievementManager.getUnlockedCount())")
                        .font(.caption2)
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Color.red)
                        .clipShape(Circle())
                        .offset(x: 12, y: -12)
                }
            }
        }
        .sheet(isPresented: $showingAchievements) {
            AchievementListView()
        }
        .onAppear {
            // Animate trophy on appear
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                trophyRotation = 5
            }
        }
    }
}

struct AchievementListView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var achievementManager = AchievementManager.shared
    
    var unlockedAchievements: [Achievement] {
        achievementManager.achievements.filter { $0.isUnlocked }
    }
    
    var lockedAchievements: [Achievement] {
        achievementManager.achievements.filter { !$0.isUnlocked }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 10) {
                        Text("🏆 ACHIEVEMENTS")
                            .font(Theme.terminalFont(size: 24))
                            .foregroundColor(Theme.terminalGreen)
                        
                        Text("\(achievementManager.getUnlockedCount()) of \(achievementManager.getTotalCount()) Unlocked")
                            .font(Theme.terminalFont(size: 14))
                            .foregroundColor(.gray)
                        
                        // Notification toggle
                        HStack(spacing: 10) {
                            Text("Notifications:")
                                .font(Theme.terminalFont(size: 12))
                                .foregroundColor(.gray)
                            
                            Button(action: {
                                achievementManager.notificationSetting = achievementManager.notificationSetting > 0 ? 0 : 1
                                HapticManager.shared.impact(.light)
                            }) {
                                Text(achievementManager.notificationSetting > 0 ? "ON" : "OFF")
                                    .font(Theme.terminalFont(size: 12))
                                    .foregroundColor(achievementManager.notificationSetting > 0 ? .green : .red)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(achievementManager.notificationSetting > 0 ? .green : .red, lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .padding(.top, 20)
                    
                    // Achievement list
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(unlockedAchievements) { achievement in
                                AchievementRow(achievement: achievement)
                            }
                            
                            // Locked achievements (showing as placeholder)
                            ForEach(lockedAchievements) { achievement in
                                LockedAchievementRow(achievement: achievement)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Theme.terminalGreen)
                }
            }
        }
    }
}

struct AchievementRow: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 15) {
            // Achievement icon
            ZStack {
                Circle()
                    .fill(Color.yellow.opacity(0.3))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "trophy.fill")
                    .font(.title2)
                    .foregroundColor(.yellow)
            }
            
            // Achievement details
            VStack(alignment: .leading, spacing: 5) {
                Text(achievement.title)
                    .font(Theme.terminalFont(size: 16))
                    .foregroundColor(.white)
                
                Text(achievement.description)
                    .font(Theme.terminalFont(size: 12))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
                
                if let unlockDate = achievement.unlockDate {
                    Text("Unlocked: \(unlockDate.formatted(date: .abbreviated, time: .shortened))")
                        .font(Theme.terminalFont(size: 10))
                        .foregroundColor(.green)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color.black.opacity(0.5))
        .overlay(Rectangle().stroke(Color.yellow.opacity(0.3), lineWidth: 1))
        .cornerRadius(8)
    }
}

struct LockedAchievementRow: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 15) {
            // Locked achievement icon
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "lock.fill")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
            
            // Achievement details (hidden)
            VStack(alignment: .leading, spacing: 5) {
                Text("???")
                    .font(Theme.terminalFont(size: 16))
                    .foregroundColor(.gray)
                
                Text("Achievement locked")
                    .font(Theme.terminalFont(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.black.opacity(0.5))
        .overlay(Rectangle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
        .cornerRadius(8)
    }
}

// MARK: - Preview

struct AchievementTrophyView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            AchievementTrophyView()
            
            AchievementListView()
        }
        .previewLayout(.sizeThatFits)
    }
} 