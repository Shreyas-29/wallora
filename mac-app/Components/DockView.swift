import SwiftUI

struct DockView: View {
    @Binding var activeIndex: Int
    let themes: [WallpaperTheme]

    var body: some View {
        // Changed to use ultraThinMaterial instead of hard dark color 
        // to match Apple UI transparency completely
        HStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(0..<themes.count, id: \.self) { index in
                        ThumbnailView(theme: themes[index], isActive: index == activeIndex) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                activeIndex = index
                            }
                        }
                    }
                }
                // Perfectly uniform 8px padding to match Apple guidelines on all sides identically
                .padding(.vertical, 8)
                .padding(.horizontal, 8) 
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading) 
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial) 
        )
    }
}

// Thumbnail component inside dock
struct ThumbnailView: View {
    let theme: WallpaperTheme
    let isActive: Bool
    let action: () -> Void
    
    @State private var hovered = false

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background Image
            AsyncImage(url: URL(string: theme.imageURL)) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .opacity(isActive ? 1.0 : (hovered ? 0.8 : 0.6))
            
            // Gradient Overlay
            LinearGradient(colors: [Color.black.opacity(0.6), .clear], startPoint: .bottom, endPoint: .center)

        }
        .frame(width: 96, height: 54)
        .clipShape(RoundedRectangle(cornerRadius: 12)) // Made 12 to match 18 outer perfectly
        .contentShape(Rectangle())
        .onTapGesture(perform: action)
        .onHover { h in
            withAnimation(.easeOut(duration: 0.2)) {
                hovered = h
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isActive ? Color.white.opacity(0.5) : Color.white.opacity(0.05), lineWidth: 1.5)
        )
    }
}
