import SwiftUI

struct CommunityView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
            
            VStack {
                // Header
                HStack {
                    Button("Back") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .padding()
                    
                    Spacer()
                    
                    Text("Community")
                        .font(.title)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button("Settings") {
                        // Settings action
                    }
                    .foregroundColor(.white)
                    .padding()
                }
                
                Spacer()
                
                // Content
                VStack(spacing: 20) {
                    Text("Community Features")
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    Text("Coming Soon...")
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
        }
    }
} 