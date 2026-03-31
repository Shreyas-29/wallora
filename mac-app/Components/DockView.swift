import SwiftUI

struct DockView: View {
    @Binding var activeIndex: Int
    let wallpapers: [Wallpaper]

    var body: some View {
        HStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(0..<wallpapers.count, id: \.self) { index in
                        ThumbnailView(wallpaper: wallpapers[index], isActive: index == activeIndex) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                activeIndex = index
                            }
                        }
                    }
                }
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

struct ThumbnailView: View {
    let wallpaper: Wallpaper
    let isActive: Bool
    let action: () -> Void
    
    @State private var hovered = false

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            BetterCachedImage(url: WallpaperStore.shared.getFullThumbURL(for: wallpaper))
                .aspectRatio(contentMode: .fill)
                .opacity(isActive ? 1.0 : (hovered ? 0.9 : 0.6))
            
            if !isActive {
                Color.black.opacity(hovered ? 0.05 : 0.2)
            }
        }
        .frame(width: 110, height: 62)
        .clipShape(RoundedRectangle(cornerRadius: 12)) 
        .contentShape(Rectangle())
        .onTapGesture(perform: action)
        .onHover { h in
            withAnimation(.easeOut(duration: 0.2)) {
                hovered = h
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isActive ? Color.white.opacity(0.8) : Color.white.opacity(0.1), lineWidth: 1.5)
        )
        .scaleEffect(isActive ? 1.03 : 1.0)
    }
}
