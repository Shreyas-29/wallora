import SwiftUI

struct NavigationBar: View {
    @Binding var selectedTab: String
    let tabs = ["Home", "Explore", "Library"]
    @Namespace private var animation

    var body: some View {
        HStack {
            // Left Side: Logo and Tabs as a single cohesive unit
            HStack(spacing: 24) {
                // Brand
                HStack(spacing: 8) {
                    Image(systemName: "sparkle")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black)
                        .frame(width: 24, height: 24)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    
                    Text("Wallora")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .tracking(-0.3)
                }
                
                // Tabs
                HStack(spacing: 0) {
                    ForEach(tabs, id: \.self) { tab in
                        Button(action: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                selectedTab = tab
                            }
                        }) {
                            Text(tab)
                                .font(.system(size: 13, weight: .regular, design: .default))
                                .foregroundColor(selectedTab == tab ? .black : Color.white.opacity(0.6))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 7)
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
                        .focusable(false) // removes keyboard focus ring
                        .contentShape(Capsule())
                    }
                }
                .padding(4)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.1)) // Glassy capsule wrapping the tabs
                )
            }
            .padding(.leading, 80) // Generous padding from the traffic lights
            
            Spacer()

            // Right Side: Only Upload (Plus) and Settings (Gear)
            HStack(spacing: 12) {
                IconButton(systemName: "plus")        // Upload icon
                IconButton(systemName: "gear")   // Settings icon
            }
            .padding(.trailing, 24)
        }
        .frame(height: 60)
        .padding(.top, 10)
    }
}

struct IconButton: View {
    let systemName: String
    @State private var isHovered = false

    var body: some View {
        Button(action: {}) {
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isHovered ? .white : Color.white.opacity(0.7))
                .frame(width: 36, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isHovered ? Color.white.opacity(0.15) : Color.white.opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(isHovered ? 0.2 : 0.05), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .focusable(false)
        .onHover { hover in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hover
            }
        }
    }
}
