import SwiftUI

struct CreateStoryView: View {
    @Binding var selectedMode: AppMode?
    
    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 48, weight: .medium))
                        .foregroundColor(.purple)
                    
                    Text("CREATE A STORY")
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .tracking(3)
                    
                    Text("Build your own narrative")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                // Placeholder content
                VStack(spacing: 20) {
                    Text("✍️ Story Builder")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("Create your own interactive stories with branching paths, custom characters, and unique worlds. Share them with the community.")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
                
                // Back button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedMode = nil
                    }
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                        Text("BACK TO MENU")
                            .font(.system(size: 16, weight: .medium, design: .monospaced))
                            .tracking(2)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.purple.opacity(0.3))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.purple.opacity(0.6), lineWidth: 1)
                            )
                    )
                }
            }
            .padding(.top, 60)
            .padding(.bottom, 40)
        }
    }
}

#Preview {
    CreateStoryView(selectedMode: .constant(.create))
} 