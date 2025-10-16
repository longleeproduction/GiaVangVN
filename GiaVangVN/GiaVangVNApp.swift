//
//  GiaVangVNApp.swift
//  GiaVangVN
//
//  Created by ORL on 15/10/25.
//

import SwiftUI
import CoreData

@main
struct GiaVangVNApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
