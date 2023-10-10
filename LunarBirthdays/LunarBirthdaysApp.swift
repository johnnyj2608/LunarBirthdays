//
//  LunarBirthdaysApp.swift
//  LunarBirthdays
//
//  Created by Johnny Jiang on 7/23/23.
//

import SwiftUI

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
                .environment(\.locale, Locale.init(identifier: "zh-CN"))
                //.environment(\.locale, Locale.init(identifier: "en"))
        }
    }
}

func clearNavigationPath() {
    NotificationCenter.default.post(name: Notification.Name("ClearPath"), object: nil)
}
