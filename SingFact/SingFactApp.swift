//
//  SingFactApp.swift
//  SingFact
//
//  Created by Vinkas on 6/12/24.
//

import FirebaseAppCheck
import FirebaseCore
import SwiftData
import SwiftUI

@main
struct SingFactApp: App {
    init() {
        SingFact.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(SingFact.modelContainer())
    }
}
