import SwiftUI

struct NavigationBar: View {
    @Binding var selectedTab: String
    let tabs = ["Home", "Explore", "Library"]
    @Namespace private var animation

    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "sparkle")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(width: 24, height: 24)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                
                Text("Wallora")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .tracking(-0.3)
            }
            .padding(.leading, 88)
            
            Spacer()

            HStack(spacing: 3) {
                ForEach(tabs, id: \.self) { tab in
                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            selectedTab = tab
                        }
                    }) {
                        Text(tab)
                            .font(.system(size: 14, weight: .regular, design: .default))
                            .foregroundColor(selectedTab == tab ? .black : Color.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                ZStack {
                                    if selectedTab == tab {
                                        Capsule()
                                            .fill(Color.white)
                                            .matchedGeometryEffect(id: "activeTabBackground", in: animation)
                                    }
                                }
                            )
                    }
                    .buttonStyle(.plain)
                    .contentShape(Capsule())
                }
            }
            .padding(6)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial) // Beautiful macOS glassy blur
            )

            Spacer()

            HStack(spacing: 12) {
                IconButton(systemName: "magnifyingglass")
                IconButton(systemName: "square.and.arrow.up")
                IconButton(systemName: "gearshape")
            }
            .padding(.trailing, 20)
        }
        .frame(height: 60)
        .padding(.top, 15)
    }
}

struct IconButton: View {
    let systemName: String
    @State private var isHovered = false

    var body: some View {
        Button(action: {}) {
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isHovered ? .white : Color.white.opacity(0.8))
                .frame(width: 38, height: 38)
                .background(
                    Circle()
                        .fill(isHovered ? Color.white.opacity(0.15) : Color.white.opacity(0.05))
                        .background(.ultraThinMaterial, in: Circle())
                )
        }
        .buttonStyle(.plain)
        .onHover { hover in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hover
            }
        }
    }
}
