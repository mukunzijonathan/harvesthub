//
//  HarvestHubApp.swift
//  HarvestHub
//
//  Created by APimpNamedSlickBack on 14/10/2026.
//

import SwiftUI
import FirebaseCore

@main
struct HarvestHubApp: App {
    init() {
        FirebaseApp.configure()      // connect to the HarvestHub Firebase project
    }

    var body: some Scene {
        WindowGroup {
            RootView()               // start at the door
        }
    }
}
