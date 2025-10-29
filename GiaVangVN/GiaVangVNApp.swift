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

    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    let persistenceController = PersistenceController.shared
    
    @State private var isSplashScreen: Bool = true

    var body: some Scene {
        WindowGroup {
            if isSplashScreen {
                SplashView()
                    .preferredColorScheme(.dark)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            self.isSplashScreen.toggle()
                        }
                    }
            } else {
                MainView()
                    .preferredColorScheme(.dark)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                        appDelegate.applicationDidBecomeActive()
                    }
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                        appDelegate.applicationWillEnterForeground()
                    }
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                        appDelegate.applicationDidEnterBackground()
                    }
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)) { _ in
                        appDelegate.applicationWillTerminate()
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
            }
        }
    }
}
