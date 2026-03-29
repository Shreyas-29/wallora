import SwiftUI

struct InfoBlock: View {
    let theme: WallpaperTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // Category Chip
            Text(theme.category)
                .font(.system(size: 11, weight: .regular, design: .default))
                .tracking(0.5)
                .foregroundColor(Color.white.opacity(0.8))
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial) // macOS Blur backdrop
                )
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .padding(.bottom, 12)

            // Title
            Text(theme.title)
                .font(.system(size: 60, weight: .light, design: .serif))
                .italic()
                .foregroundColor(.white)
                .tracking(-1.5)
                .shadow(color: .black.opacity(0.3), radius: 10, y: 4)
                .padding(.bottom, 12)

            // Meta Line
            HStack(spacing: 6) {
                MetaText(text: theme.resolution)
                MetaSeparator()
                MetaText(text: theme.dimensions)
                MetaSeparator()
                MetaText(text: theme.size)
            }
            // Drastically reduced gap down to Set Wallpaper per user request
            .padding(.bottom, 18) 

            // Action Buttons
            HStack(spacing: 12) {
                SetButton()
                SaveButton()
            }
        }
    }
}

struct MetaText: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 13, weight: .regular, design: .rounded))
            .foregroundColor(Color.white.opacity(0.75))
            .tracking(0.2)
    }
}

struct MetaSeparator: View {
    var body: some View {
        Text("·")
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(Color.white.opacity(0.4))
    }
}

struct SetButton: View {
    @State private var hovered = false

    var body: some View {
        Button(action: {}) {
            Text("Set Wallpaper")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .tracking(0.1)
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
                .background(hovered ? Color.white.opacity(0.85) : Color.white) // Lighter on hover
                .foregroundColor(.black)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .onHover { h in 
            // Simple smooth 0.3s opacity transition without scale effect
            withAnimation(.easeInOut(duration: 0.2)) { hovered = h } 
        }
    }
}

struct SaveButton: View {
    @State private var hovered = false
    @State private var isSaved = false 

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isSaved.toggle()
            }
        }) {
            ZStack {
                // Removed Border explicitly to maintain absolute consistency with right Nav icons
                Circle()
                    .fill(hovered ? Color.white.opacity(0.15) : Color.white.opacity(0.05))
                    .background(.ultraThinMaterial, in: Circle()) // Same matching glass effect
                    
                Image(systemName: isSaved ? "heart.fill" : "heart")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(isSaved ? .red : (hovered ? .white : Color.white.opacity(0.8)))
            }
            .frame(width: 40, height: 40) // Slightly smaller, tightly matched, removed bouncy scale
        }
        .buttonStyle(.plain)
        .onHover { h in withAnimation(.easeInOut(duration: 0.2)) { hovered = h } }
    }
}
