import SwiftUI

struct ShaderView: View {
    let corruption: Double
    let sanity: Double
    let isBroken: Bool
    
    var body: some View {
        ZStack {
            // Base background
            Theme.darkBackground
                .ignoresSafeArea()
            
            // Corruption overlay
            if corruption > 0 {
                Color.red.opacity(corruption * 0.3)
                    .ignoresSafeArea()
            }
            
            // Sanity overlay
            if sanity < 0.5 {
                Color.blue.opacity((0.5 - sanity) * 0.4)
                    .ignoresSafeArea()
            }
            
            // Broken state overlay
            if isBroken {
                Color.purple.opacity(0.2)
                    .ignoresSafeArea()
            }
        }
    }
} 