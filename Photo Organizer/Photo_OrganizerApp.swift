//
//  Photo_OrganizerApp.swift
//  Photo Organizer
//
//  Created by feng on 8/17/24.
//

import SwiftUI

@main
struct PhotoOrganizerApp: App {
    @State private var isFirstLaunch: Bool = !UserDefaults.standard.bool(forKey: "HasLaunchedBefore")
    @State private var welcomeWindow: NSWindow?
    @State private var isWelcomePresented: Bool = true

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    if isFirstLaunch {
                        UserDefaults.standard.set(true, forKey: "HasLaunchedBefore")
                        showWelcomeWindow()
                    }
                }
        }
    }

    private func showWelcomeWindow() {
        let welcomeView = WelcomeView(isPresented: $isWelcomePresented) // 传递绑定参数
        let welcomeWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable],
            backing: .buffered, defer: false
        )
        welcomeWindow.title = "Welcome to Photo Organizer"
        welcomeWindow.contentView = NSHostingView(rootView: welcomeView)
        welcomeWindow.makeKeyAndOrderFront(nil)
        welcomeWindow.center()
        self.welcomeWindow = welcomeWindow
    }
}
