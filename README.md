# Wallora 🖥️

> A lightweight macOS menu bar app that brings your desktop to life by setting any video as your live wallpaper.

![macOS Support](https://img.shields.io/badge/macOS-13.0+-blue?style=for-the-badge&logo=apple)
![SwiftUI](https://img.shields.io/badge/SwiftUI-native-orange?style=for-the-badge&logo=swift)

## Features ✨

- **Live Video Wallpapers:** Set any `.mp4`, `.mov`, or QuickTime video as your desktop background to create a dynamic workspace.
- **Multi-Monitor Support:** Automatically detects your displays and seamlessly loops the video across every connected screen.
- **Clean & Minimal UI:** Designed natively for macOS featuring a sleek, black-and-white menu bar interface that stays completely out of your way.
- **Resource Friendly:** Videos are automatically muted and looped efficiently using `AVFoundation`, preventing display sleep interruption and preserving battery.

## Getting Started 🚀

### Prerequisites
- macOS 13.0 or later
- Xcode 15 or later (if building from source)

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/Shreyas-29/wallora.git
   ```
2. Open `mac-app.xcodeproj` in Xcode.
3. Select your Mac as the build destination and press `Cmd + R` to run.
4. Wallora will appear as a small display icon in your Mac's top menu bar.

## Usage 💡
1. Click the **Wallora icon** in the top-right menu bar.
2. Click **Upload Video** (or the folder icon) and select a video file from your Mac.
3. Click **Apply Wallpaper** and watch your desktop come to life!
4. You can pause the wallpaper at any time by clicking **Stop Wallpaper** or quit entirely via the `...` settings menu.

## Tech Stack 🛠️
- **SwiftUI** for the user interface and menu bar integration (`MenuBarExtra`).
- **AppKit** for positioning the borderless window at the desktop level (`NSWindow.Level.desktopWindow`).
- **AVFoundation** (`AVQueuePlayer`, `AVPlayerLooper`, `AVPlayerLayer`) for highly efficient, seamless video looping.

---
*Built with ❤️ for macOS.*
