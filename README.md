<div align="center">
  <img src="https://github.com/user-attachments/assets/9ce8e054-f44a-49da-8f02-a9b36234d8fc" alt="Wallora Logo" width="50"/>
  <h1>Wallora</h1>
  <p>A minimalist macOS menu bar app for live video desktop wallpapers.</p>
</div>

## ✨ Features
- **Live Backgrounds**: Set any `.mp4` or `.mov` as your wallpaper.
- **Multi-Monitor**: Loops seamlessly across all your displays.
- **Minimal UI**: Clean, native Mac menu bar interface.
- **Efficient**: Silent playback (auto-muted) using `AVFoundation`.

## 🚀 Getting Started
1. Clone the repository:
   ```bash
   git clone https://github.com/Shreyas-29/wallora.git
   ```
2. Open `mac-app.xcodeproj` in Xcode 15+.
3. Select your Mac as the build destination and press `Cmd + R`.

## 💡 Usage
1. Click the menu bar icon.
2. Select an MP4 video file.
3. Click "Apply Wallpaper".

## 🛠️ Tech Stack
- **SwiftUI**: Menu bar UI (`MenuBarExtra`).
- **AppKit**: Borderless background windows.
- **AVFoundation**: Hardware-accelerated video looping.
