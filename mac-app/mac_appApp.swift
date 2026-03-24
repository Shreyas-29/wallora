//
//  mac_appApp.swift
//  mac-app
//
//  Created by shreyas sihasane on 09/12/25.
//

import SwiftUI

@main
struct mac_appApp: App {
    var body: some Scene {
        MenuBarExtra("Wallora", image: "MenuBarIcon") {
            ContentView()
        }
        .menuBarExtraStyle(.window) // Creates a popover-style menu
    }
}
