import SwiftUI

struct HomeView: View {
    @State private var activeIndex = 0
    @State private var selectedTab = "Home"
    @State private var exploreSearchText = ""
    @State private var textBlur: CGFloat = 0

    var themes: [WallpaperTheme] {
        switch selectedTab {
        case "Home": return homeWallpapers
        case "Explore": return exploreWallpapers
        case "Library": return savedWallpapers + userUploadedWallpapers
        default: return homeWallpapers
        }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Background Wallpaper layer ONLY FOR HOME
            if selectedTab == "Home" {
                GeometryReader { geo in
                    ZStack {
                        ForEach(0..<themes.count, id: \.self) { index in
                            if let imageURL = URL(string: themes[index].imageURL) {
                                AsyncImage(url: imageURL) { phase in
                                    if let image = phase.image {
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: geo.size.width, height: geo.size.height)
                                            .clipped()
                                    } else {
                                        Color.black
                                            .frame(width: geo.size.width, height: geo.size.height)
                                    }
                                }
                                .opacity(activeIndex == index ? 1.0 : 0.0)
                                .animation(.easeOut(duration: 0.55), value: activeIndex)
                            }
                        }
                    }
                }
                .ignoresSafeArea()
                .transition(.opacity)

                // Vignettes for better text contrast
                LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.35), .clear, .clear, Color.black.opacity(0.85)]), startPoint: .top, endPoint: .bottom)
                    .blendMode(.multiply)
                    .ignoresSafeArea()

                RadialGradient(gradient: Gradient(colors: [.clear, Color.black.opacity(0.2)]), center: UnitPoint(x: 0.7, y: 0.40), startRadius: 100, endRadius: 800)
                    .blendMode(.multiply)
                    .ignoresSafeArea()
            }

            // UI Layer
            GeometryReader { layoutGeo in
                VStack(spacing: 0) {
                    NavigationBar(selectedTab: $selectedTab)
                        // Align perfectly horizontally with traffic lights by removing artificial spacing
                    
                    Spacer()

                    // Bottom Tab Switcher
                    if selectedTab == "Home" {
                        // THE HERO DOCK LAYOUT
                        HStack(alignment: .bottom, spacing: 0) {
                            
                            // Left Info Block with active BLUR animation on changing
                            InfoBlock(theme: themes[activeIndex])
                                .frame(width: layoutGeo.size.width * 0.35, alignment: .leading)
                                .id(themes[activeIndex].id)
                                .transition(.opacity.combined(with: .scale(scale: 0.96, anchor: .bottomLeading)))
                                .blur(radius: textBlur)
                            
                            Spacer()
                            
                            // Right Side Dock
                            DockView(activeIndex: $activeIndex, themes: themes)
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
                        // EXPLORE GRID GALLERY
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
                                
                                Text("Trending Animations")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], spacing: 30) {
                                    ForEach(exploreWallpapers) { theme in
                                        ThemeCard(theme: theme)
                                    }
                                }
                                
                                Text("New Arrivals")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.top, 30)
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], spacing: 30) {
                                    ForEach(exploreWallpapers.reversed()) { theme in
                                        ThemeCard(theme: theme)
                                    }
                                }
                            }
                            .padding(.horizontal, 40)
                            .padding(.top, 20)
                        }
                        .transition(.opacity)
                    } else if selectedTab == "Library" {
                        // LIBRARY GRID GALLERY
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 20) {
                                Text("Saved Wallpapers")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], spacing: 30) {
                                    ForEach(savedWallpapers) { theme in
                                        ThemeCard(theme: theme)
                                    }
                                }
                                
                                Text("My Uploads")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.top, 30)
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], spacing: 30) {
                                    ForEach(userUploadedWallpapers) { theme in
                                        ThemeCard(theme: theme)
                                    }
                                }
                            }
                            .padding(.horizontal, 40)
                            .padding(.top, 20)
                        }
                        .transition(.opacity)
                    }
                }
            }
            .ignoresSafeArea(.all, edges: .top)
        }
        .frame(minWidth: 900, idealWidth: 1200, minHeight: 600, idealHeight: 800)
        .background(Color.black)
    }
}

struct ThemeCard: View {
    let theme: WallpaperTheme
    @State private var isHovered = false
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background Image
            AsyncImage(url: URL(string: theme.imageURL)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Color.white.opacity(0.05)
                }
            }
            .frame(height: 160)
            
            // Dark gradient overlay for text readability
            LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                Spacer()
                Text(theme.category)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.4))
                    .cornerRadius(6)
                
                Text(theme.title)
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
