import SwiftUI
import Foundation
import Combine

struct HomeView: View {
    @StateObject private var store = WallpaperStore.shared
    @StateObject private var admin = AdminManager.shared
    @State private var activeIndex = 0 
    @State private var selectedTab = "Home"
    @State private var exploreSearchText = ""
    @State private var textBlur: CGFloat = 0
    @State private var selectedWallpaper: Wallpaper? // THE CHOSEN ONE

    var currentWallpapers: [Wallpaper] {
        switch selectedTab {
        case "Home": 
            return Array(store.wallpapers.prefix(5))
        case "Explore": 
            if exploreSearchText.isEmpty { return store.wallpapers }
            return store.wallpapers.filter { $0.title.localizedCaseInsensitiveContains(exploreSearchText) || $0.category.localizedCaseInsensitiveContains(exploreSearchText) }
        case "Library": 
            return [] 
        default: 
            return store.wallpapers
        }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // BACKGROUND VIDEO: OPTIMIZED
            if selectedTab == "Home", !currentWallpapers.isEmpty {
                let safeIndex = activeIndex < currentWallpapers.count ? activeIndex : 0
                let wp = currentWallpapers[safeIndex]
                
                GeometryReader { geo in
                    if let videoURL = WallpaperStore.shared.getFullVideoURL(for: wp) {
                        let thumbURL = WallpaperStore.shared.getFullThumbURL(for: wp)
                        VideoPreviewPlayer(videoURL: videoURL, thumbURL: thumbURL)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geo.size.width, height: geo.size.height)
                            .opacity(0.6)
                            .id(wp.id) 
                    }
                }
                .ignoresSafeArea()
                .transition(.opacity)

                LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.4), .clear, .clear, Color.black.opacity(0.9)]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            }

            // UI LAYER
            GeometryReader { layoutGeo in
                VStack(spacing: 0) {
                    NavigationBar(selectedTab: $selectedTab)
                    
                    if store.isLoading {
                        Spacer()
                        ProgressView().tint(.white)
                        Spacer()
                    } else {
                        ZStack {
                            if selectedTab == "Home", !currentWallpapers.isEmpty {
                                homeTab(layoutGeo: layoutGeo)
                            } else if selectedTab == "Explore" {
                                exploreTab()
                            } else if selectedTab == "Library" {
                                libraryTab()
                            } else if selectedTab == "Upload", admin.isAdminUnlocked {
                                AdminView()
                            }
                        }
                    }
                }
            }
            .ignoresSafeArea(.all, edges: .top)
        }
        .frame(minWidth: 900, minHeight: 600)
        .sheet(item: $selectedWallpaper) { wp in
            WallpaperDetailView(wallpaper: wp) // IMMERSIVE DETAIL PAGE
        }
    }
    
    // MARK: - Tab Views
    
    private func homeTab(layoutGeo: GeometryProxy) -> some View {
        let safeIndex = activeIndex < currentWallpapers.count ? activeIndex : 0
        return VStack {
            Spacer()
            HStack(alignment: .bottom, spacing: 0) {
                InfoBlock(wallpaper: currentWallpapers[safeIndex])
                    .frame(width: layoutGeo.size.width * 0.35, alignment: .leading)
                    .id(currentWallpapers[safeIndex].id)
                    .transition(.opacity.combined(with: .scale(scale: 0.98, anchor: .bottomLeading)))
                
                Spacer()
                
                DockView(activeIndex: $activeIndex, wallpapers: currentWallpapers)
                    .frame(alignment: .trailing)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
            .onChange(of: activeIndex) { _ in
                textBlur = 10
                withAnimation { textBlur = 0 }
            }
        }
    }
    
    private func exploreTab() -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                // Search
                HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(.white.opacity(0.5))
                    TextField("Search library...", text: $exploreSearchText)
                        .textFieldStyle(.plain).foregroundColor(.white)
                }
                .padding(12).background(Color.white.opacity(0.08)).cornerRadius(12)
                
                // Categories
                ForEach(Array(Set(store.wallpapers.map { $0.category })).sorted(), id: \.self) { cat in
                    let catWallpapers = currentWallpapers.filter { $0.category == cat }
                    if !catWallpapers.isEmpty {
                        Text(cat).font(.headline).foregroundColor(.white).padding(.leading, 4)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 320), spacing: 24)], spacing: 32) {
                            ForEach(catWallpapers) { wp in
                                WallpaperCard(wallpaper: wp) {
                                    // NO MORE JUMPING TO HOME! Now we show the Detail View.
                                    withAnimation(.spring()) {
                                        selectedWallpaper = wp
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(40)
        }
    }
    
    private func libraryTab() -> some View {
        Text("Library").foregroundColor(.white)
    }
}

struct WallpaperCard: View {
    let wallpaper: Wallpaper
    let onSelect: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                BetterCachedImage(url: WallpaperStore.shared.getFullThumbURL(for: wallpaper))
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 190).clipped()
                
                if isHovered, let videoURL = WallpaperStore.shared.getFullVideoURL(for: wallpaper) {
                    VideoPreviewPlayer(videoURL: videoURL, thumbURL: WallpaperStore.shared.getFullThumbURL(for: wallpaper))
                        .frame(height: 190).clipped()
                }
            }
            .frame(height: 190).clipShape(RoundedRectangle(cornerRadius: 16))
            .onTapGesture(perform: onSelect) // CLICK TO OPEN DETAIL
            .onHover { isHovered = $0 }
            
            Text(wallpaper.title).font(.system(size: 15, weight: .medium)).foregroundColor(.white)
        }
    }
}
