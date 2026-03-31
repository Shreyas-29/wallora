import SwiftUI
import Foundation

struct HomeView: View {
    @StateObject private var store = WallpaperStore.shared
    @State private var activeIndex = 0
    @State private var selectedTab = "Home"
    @State private var exploreSearchText = ""
    @State private var textBlur: CGFloat = 0

    var currentWallpapers: [Wallpaper] {
        switch selectedTab {
        case "Home": 
            return Array(store.wallpapers.prefix(5))
        case "Explore": 
            if exploreSearchText.isEmpty {
                return store.wallpapers
            } else {
                return store.wallpapers.filter { $0.title.localizedCaseInsensitiveContains(exploreSearchText) || $0.category.localizedCaseInsensitiveContains(exploreSearchText) }
            }
        case "Library": 
            return [] 
        default: 
            return store.wallpapers
        }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Background Wallpaper layer ONLY FOR HOME
            if selectedTab == "Home", !currentWallpapers.isEmpty {
                GeometryReader { geo in
                    ZStack {
                        ForEach(0..<currentWallpapers.count, id: \.self) { index in
                            BetterCachedImage(url: WallpaperStore.shared.getFullThumbURL(for: currentWallpapers[index]))
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geo.size.width, height: geo.size.height)
                                .clipped()
                                .opacity(activeIndex == index ? 0.6 : 0.0)
                                .animation(.easeOut(duration: 0.55), value: activeIndex)
                        }
                    }
                }
                .ignoresSafeArea()
                .transition(.opacity)

                LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.4), .clear, .clear, Color.black.opacity(0.9)]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            }

            // UI Layer
            GeometryReader { layoutGeo in
                VStack(spacing: 0) {
                    NavigationBar(selectedTab: $selectedTab)
                    
                    if store.isLoading {
                        Spacer()
                        ProgressView("Fetching library...")
                            .tint(.white)
                        Spacer()
                    } else {
                        Spacer()

                        if selectedTab == "Home", !currentWallpapers.isEmpty {
                            HStack(alignment: .bottom, spacing: 0) {
                                InfoBlock(wallpaper: currentWallpapers[activeIndex])
                                    .frame(width: layoutGeo.size.width * 0.35, alignment: .leading)
                                    .id(currentWallpapers[activeIndex].id)
                                    .transition(.opacity.combined(with: .scale(scale: 0.98, anchor: .bottomLeading)))
                                    .blur(radius: textBlur)
                                
                                Spacer()
                                
                                // Fixed Dock Alignment to fit 5 thumbnails perfectly
                                DockView(activeIndex: $activeIndex, wallpapers: currentWallpapers)
                                    .frame(width: 610, alignment: .trailing) // (110 width * 5) + (8 spacing * 4) + padding
                            }
                            .padding(.horizontal, 40)
                            .padding(.bottom, 40)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                            .onChange(of: activeIndex) { _ in
                                textBlur = 10
                                withAnimation(.easeOut(duration: 0.5)) {
                                    textBlur = 0
                                }
                            }
                        } else if selectedTab == "Explore" {
                            ScrollView(.vertical, showsIndicators: false) {
                                VStack(alignment: .leading, spacing: 20) {
                                    HStack {
                                        Image(systemName: "magnifyingglass").foregroundColor(.white.opacity(0.5))
                                        TextField("Search library...", text: $exploreSearchText)
                                            .textFieldStyle(.plain)
                                            .foregroundColor(.white)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(Color.white.opacity(0.08))
                                    .cornerRadius(12)
                                    .padding(.bottom, 15)
                                    
                                    ForEach(Array(Set(store.wallpapers.map { $0.category })).sorted(), id: \.self) { cat in
                                        let catWallpapers = currentWallpapers.filter { $0.category == cat }
                                        if !catWallpapers.isEmpty {
                                            Text(cat)
                                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                                .foregroundColor(.white)
                                                .padding(.leading, 4)
                                            
                                            // Grid with fixed height to avoid "pinched" look
                                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 320), spacing: 24)], spacing: 32) {
                                                ForEach(catWallpapers) { wp in
                                                    WallpaperCard(wallpaper: wp)
                                                }
                                            }
                                            .padding(.bottom, 40)
                                        }
                                    }
                                }
                                .padding(.horizontal, 40)
                                .padding(.top, 20)
                            }
                            .transition(.opacity)
                        } else if selectedTab == "Library" {
                            VStack {
                                Spacer()
                                Text("Premium features coming soon.")
                                    .foregroundColor(.white.opacity(0.4))
                                Spacer()
                            }
                        }
                    }
                }
            }
            .ignoresSafeArea(.all, edges: .top)
        }
        .frame(minWidth: 900, idealWidth: 1200, minHeight: 600, idealHeight: 800)
        .background(Color.black)
    }
}

struct WallpaperCard: View {
    let wallpaper: Wallpaper
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .center) {
                // Background Thumbnail (Cached)
                BetterCachedImage(url: WallpaperStore.shared.getFullThumbURL(for: wallpaper))
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 190) // Increased height for better aspect ratio
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // Hovered Video Preview
                if isHovered, let videoURL = WallpaperStore.shared.getFullVideoURL(for: wallpaper) {
                    let thumbURL = WallpaperStore.shared.getFullThumbURL(for: wallpaper)
                    VideoPreviewPlayer(videoURL: videoURL, thumbURL: thumbURL)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .transition(.opacity.animation(.easeInOut(duration: 0.3)))
                }
                
                // Shadow / Lift effect overlay
                if isHovered {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.05))
                        .shadow(color: .white.opacity(0.1), radius: 20)
                }
            }
            .frame(height: 190)
            .shadow(color: .black.opacity(0.3), radius: 15, y: 10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(wallpaper.title)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                
                Text(wallpaper.category)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.leading, 4)
        }
        .onHover { hover in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isHovered = hover
            }
        }
    }
}
