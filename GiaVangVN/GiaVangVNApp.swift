//
//  GiaVangVNApp.swift
//  GiaVangVN
//
//  Created by L7 Mobile on 15/10/25.
//

import SwiftUI
import CoreData

@main
struct GiaVangVNApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
