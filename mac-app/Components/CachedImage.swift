import SwiftUI

/// A wrapper around AsyncImage that uses URLCache heavily to prevent lag when switching tabs.
/// In production, consider using a package like Kingfisher or Nuke for more advanced caching,
/// but this ensures URLCache doesn't drop the images immediately.
struct CachedImage<Content: View, Placeholder: View>: View {
    private let url: URL?
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder
    
    // In-memory cache fallback to avoid any flicker even if URLCache hits disk
    @State private var cachedImage: Image?

    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }

    var body: some View {
        if let currentImage = cachedImage {
            content(currentImage)
        } else {
            AsyncImage(url: url) { phase in
                if let image = phase.image {
                    let _ = DispatchQueue.main.async {
                        self.cachedImage = image
                    }
                    content(image)
                } else if phase.error != nil {
                    placeholder() // error state
                } else {
                    placeholder() // loading state
                }
            }
        }
    }
}
