import SwiftUI

struct HomeView: View {
    @State private var activeIndex = 0
    @State private var selectedTab = "Home"

    let themes = sampleWallpapers

    var body: some View {
        ZStack {
            // Background Image
            if let imageURL = URL(string: themes[activeIndex].imageURL) {
                AsyncImage(url: imageURL) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .transition(.opacity.animation(.easeInOut(duration: 0.55)))
                    } else {
                        Color.black
                    }
                }
                .id(imageURL) // Used to trigger transition effect
                .ignoresSafeArea()
            }

            // Vignette Overlay
            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.28), .clear, .clear, Color.black.opacity(0.82)]), startPoint: .top, endPoint: .bottom)
                .blendMode(.multiply)
                .ignoresSafeArea()

            RadialGradient(gradient: Gradient(colors: [.clear, Color.black.opacity(0.35)]), center: UnitPoint(x: 0.65, y: 0.40), startRadius: 100, endRadius: 800)
                .blendMode(.multiply)
                .ignoresSafeArea()

            // Main Content Layout
            VStack {
                NavigationBar(selectedTab: $selectedTab)
                
                Spacer()

                HStack(alignment: .bottom) {
                    InfoBlock(theme: themes[activeIndex])
                        .id(activeIndex) // triggers view transition
                        .transition(.scale(scale: 0.98, anchor: .bottomLeading).combined(with: .opacity).animation(.easeOut(duration: 0.25)))
                        .padding(.leading, 32)
                        .padding(.bottom, 130)

                    Spacer()
                }
            }

            // Floating Dock (Bottom Center)
            VStack {
                Spacer()
                DockView(activeIndex: $activeIndex, themes: themes)
                    .padding(.bottom, 22)
            }
        }
        .frame(minWidth: 900, idealWidth: 1120, minHeight: 600, idealHeight: 730)
        .background(Color.black)
    }
}
