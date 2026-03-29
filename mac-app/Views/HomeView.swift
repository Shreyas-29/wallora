import SwiftUI

struct HomeView: View {
    @State private var activeIndex = 0
    @State private var selectedTab = "Home"
    @State private var textBlur: CGFloat = 0

    let themes = sampleWallpapers

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

                    // Bottom Split layout (30% Left / 70% Right layout mathematically)
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
                    .onChange(of: activeIndex) { _ in
                        // Fires blur pulse correctly mapped to index toggle
                        textBlur = 12
                        withAnimation(.easeOut(duration: 0.6)) {
                            textBlur = 0
                        }
                    }
                }
            }
        }
        .frame(minWidth: 900, idealWidth: 1200, minHeight: 600, idealHeight: 800)
        .background(Color.black)
    }
}
