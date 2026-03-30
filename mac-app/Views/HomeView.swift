import SwiftUI

struct HomeView: View {
    @State private var activeIndex = 0
    @State private var selectedTab = "Home"
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
            // Smart Pre-loader: Instantly loads ALL images behind the scenes
            // so there is literally 0.0 seconds of black-out lag when clicking thumbnails
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
                            // Only the active image is completely visible, others are hidden instantly but PRE-LOADED
                            .opacity(activeIndex == index ? 1.0 : 0.0)
                            .animation(.easeOut(duration: 0.55), value: activeIndex)
                        }
                    }
                }
            }
            .ignoresSafeArea()
            .onChange(of: selectedTab) { _ in
                // Reset index safely when changing tabs to prevent array out of bounds
                activeIndex = 0
            }

            // Vignettes for better text contrast
            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.35), .clear, .clear, Color.black.opacity(0.85)]), startPoint: .top, endPoint: .bottom)
                .blendMode(.multiply)
                .ignoresSafeArea()

            RadialGradient(gradient: Gradient(colors: [.clear, Color.black.opacity(0.2)]), center: UnitPoint(x: 0.7, y: 0.40), startRadius: 100, endRadius: 800)
                .blendMode(.multiply)
                .ignoresSafeArea()

            // UI Layer
            GeometryReader { layoutGeo in
                VStack(spacing: 0) {
                    NavigationBar(selectedTab: $selectedTab)
                        .padding(.top, 10)
                    
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
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], spacing: 30) {
                                ForEach(themes) { theme in
                                    Rectangle()
                                        .fill(Color.white.opacity(0.05))
                                        .frame(height: 160)
                                        .cornerRadius(12)
                                        .overlay(Text("Community Grid Placeholder").foregroundColor(.white.opacity(0.3)))
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
                                        Rectangle().fill(Color.white.opacity(0.05)).frame(height: 160).cornerRadius(12)
                                    }
                                }
                                
                                Text("My Uploads")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.top, 30)
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], spacing: 30) {
                                    ForEach(userUploadedWallpapers) { theme in
                                        Rectangle().fill(Color.white.opacity(0.05)).frame(height: 160).cornerRadius(12)
                                    }
                                }
                            }
                            .padding(.horizontal, 40)
                            .padding(.top, 20)
                        }
                        .transition(.opacity)
                    }
                }
                .animation(.easeInOut(duration: 0.4), value: selectedTab)
            }
        }
        .frame(minWidth: 900, idealWidth: 1200, minHeight: 600, idealHeight: 800)
        .background(Color.black)
    }
}
