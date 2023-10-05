//
//  LunarBirthdaysApp.swift
//  LunarBirthdays
//
//  Created by Johnny Jiang on 7/23/23.
//

import SwiftUI
import GoogleSignIn

@main
struct LunarBirthdaysApp: App {
    @StateObject private var dataController = DataController.shared
    @AppStorage("darkMode") private var darkMode = true
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var path = NavigationPath()
    
    var body: some Scene {
        WindowGroup {
            WrapperView(path: $path)
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .preferredColorScheme(darkMode ? .dark : .light)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    UIApplication.shared.applicationIconBadgeNumber = 0
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                    UIApplication.shared.applicationIconBadgeNumber = 0
                }
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ClearPath"))) { _ in
                    path.removeLast(path.count)
                }
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
                .onAppear {
                    GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                        // Check if `user` exists; otherwise, do something with `error`
                    }
                }
        }
    }
}

func clearNavigationPath() {
    NotificationCenter.default.post(name: Notification.Name("ClearPath"), object: nil)
}
