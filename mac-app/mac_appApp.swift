//
//  mac_appApp.swift
//  mac-app
//
//  Created by shreyas sihasane on 09/12/25.
//

import SwiftUI

// Option B: AppKit Hook to push Traffic Lights down and align them with the NavigationBar
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Find the main window and inject a custom thickness to push traffic lights down
        if let window = NSApplication.shared.windows.first {
            window.titlebarSeparatorStyle = .none
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
            
            // This natively forces the macOS traffic lights to perfectly vertically center 
            // within a thicker 54px hit-box, aligning them flawlessly with our navbar.
            let customToolbar = NSToolbar()
            customToolbar.showsBaselineSeparator = false
            window.toolbar = customToolbar
        }
    }
}

@main
struct mac_appApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .preferredColorScheme(.dark)
        }
        .windowStyle(.hiddenTitleBar)

        MenuBarExtra("Wallora", systemImage: "sparkle") {
            ContentView()
        }
        .menuBarExtraStyle(.window) // Creates a popover-style menu
    }
}
