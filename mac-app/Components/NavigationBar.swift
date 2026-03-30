import SwiftUI

struct NavigationBar: View {
    @Binding var selectedTab: String
    let tabs = ["Home", "Explore", "Library"]
    @Namespace private var animation

    var body: some View {
        ZStack {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "sparkle")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white)
                    
                    Text("Wallora")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(.white)
                        .tracking(-0.3)
                }
                .padding(.leading, 80)
                
                Spacer()
            }
            
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
                            .contentShape(Rectangle())
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
                    .focusable(false)
                }
            }
            .padding(4)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.1))
            )
            
            HStack {
                Spacer()
                HStack(spacing: 12) {
                    IconButton(systemName: "plus")
                    IconButton(systemName: "gear")
                }
                .padding(.trailing, 24)
            }
        }
        .frame(height: 50)
        .padding(.top, 20)
    }
}

struct IconButton: View {
    let systemName: String
    @State private var isHovered = false

    var body: some View {
        Button(action: {}) {
            Image(systemName: systemName)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(isHovered ? .white : Color.white.opacity(0.7))
                .frame(width: 32, height: 32)
                .contentShape(Rectangle())
                .background(
                    RoundedRectangle(cornerRadius: 99)
                        .fill(isHovered ? Color.white.opacity(0.15) : Color.white.opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 99)
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
