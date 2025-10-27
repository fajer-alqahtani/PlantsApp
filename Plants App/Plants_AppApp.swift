//
//  Plants_AppApp.swift
//  Plants App
//
//  Created by Fajer alQahtani on 28/04/1447 AH.
//

import SwiftUI
import SwiftData

@main
struct Plants_AppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    // Ask for notification permission on launch
                    _ = try? await NotificationManager.requestAuthorization()
                }
        }
        // This line wires SwiftData up for Plant
        .modelContainer(for: Plant.self)
    }
}
