import SwiftUI

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
            return [] // Track downloaded or liked ones later
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
                            CachedImage(url: WallpaperStore.shared.getFullThumbURL(for: currentWallpapers[index])) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: geo.size.width, height: geo.size.height)
                                    .clipped()
                            } placeholder: {
                                Color.black
                            }
                            .opacity(activeIndex == index ? 0.7 : 0.0)
                            .animation(.easeOut(duration: 0.55), value: activeIndex)
                        }
                    }
                }
                .ignoresSafeArea()
                .transition(.opacity)

                // Vignettes for better text contrast
                LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.35), .clear, .clear, Color.black.opacity(0.85)]), startPoint: .top, endPoint: .bottom)
                    .blendMode(.multiply)
                    .ignoresSafeArea()
            }

            // UI Layer
            GeometryReader { layoutGeo in
                VStack(spacing: 0) {
                    NavigationBar(selectedTab: $selectedTab)
                    
                    if store.isLoading {
                        Spacer()
                        ProgressView("Loading library...")
                        Spacer()
                    } else {
                        Spacer()

                        // Bottom Tab Switcher
                        if selectedTab == "Home", !currentWallpapers.isEmpty {
                            HStack(alignment: .bottom, spacing: 0) {
                                InfoBlock(wallpaper: currentWallpapers[activeIndex])
                                    .frame(width: layoutGeo.size.width * 0.35, alignment: .leading)
                                    .id(currentWallpapers[activeIndex].id)
                                    .transition(.opacity.combined(with: .scale(scale: 0.96, anchor: .bottomLeading)))
                                    .blur(radius: textBlur)
                                
                                Spacer()
                                
                                DockView(activeIndex: $activeIndex, wallpapers: currentWallpapers)
                                    .frame(width: layoutGeo.size.width * 0.55, alignment: .trailing)
                            }
                            .padding(.horizontal, 40)
                            .padding(.bottom, 40)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                            .onChange(of: activeIndex) { _ in
                                textBlur = 12
                                withAnimation(.easeOut(duration: 0.6)) {
                                    textBlur = 0
                                }
                            }
                        } else if selectedTab == "Explore" {
                            ScrollView(.vertical, showsIndicators: false) {
                                VStack(alignment: .leading, spacing: 20) {
                                    // Search Bar
                                    HStack {
                                        Image(systemName: "magnifyingglass").foregroundColor(.white.opacity(0.5))
                                        TextField("Search community wallpapers...", text: $exploreSearchText)
                                            .textFieldStyle(.plain)
                                            .foregroundColor(.white)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(Color.white.opacity(0.08))
                                    .cornerRadius(12)
                                    .padding(.bottom, 15)
                                    
                                    // Categories (Grouped)
                                    ForEach(Array(Set(store.wallpapers.map { $0.category })).sorted(), id: \.self) { cat in
                                        let catWallpapers = currentWallpapers.filter { $0.category == cat }
                                        if !catWallpapers.isEmpty {
                                            Text(cat)
                                                .font(.system(size: 18, weight: .semibold))
                                                .foregroundColor(.white)
                                            
                                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], spacing: 30) {
                                                ForEach(catWallpapers) { wp in
                                                    WallpaperCard(wallpaper: wp)
                                                }
                                            }
                                            .padding(.bottom, 30)
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
                                Text("Your liked and downloaded wallpapers will appear here.")
                                    .foregroundColor(.secondary)
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
        ZStack(alignment: .bottomLeading) {
            CachedImage(url: WallpaperStore.shared.getFullThumbURL(for: wallpaper)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.white.opacity(0.05)
            }
            .frame(height: 160)
            
            LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
            
            VStack(alignment: .leading, spacing: 6) {
                Spacer()
                Text(wallpaper.category)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.4))
                    .cornerRadius(6)
                
                Text(wallpaper.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(12)
        }
        .frame(height: 160)
        .cornerRadius(12)
        .scaleEffect(isHovered ? 1.02 : 1)
        .shadow(color: Color.black.opacity(isHovered ? 0.4 : 0), radius: 10, y: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(isHovered ? 0.3 : 0.0), lineWidth: 1.5)
        )
        .onHover { hover in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isHovered = hover
            }
        }
    }
}
