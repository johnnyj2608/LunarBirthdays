//
//  LunarBirthdaysApp.swift
//  LunarBirthdays
//
//  Created by Johnny Jiang on 7/23/23.
//

import SwiftUI
import GoogleMobileAds

@main
struct LunarBirthdaysApp: App {
    @StateObject private var dataController = DataController.shared
    @AppStorage("darkMode") private var darkMode = true
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var path = NavigationPath()
    
    var body: some Scene {
        WindowGroup {
            ContentView(path: $path)
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
        }
    }
}

func clearNavigationPath() {
    NotificationCenter.default.post(name: Notification.Name("ClearPath"), object: nil)
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        registerForLocalNotifications()
        UNUserNotificationCenter.current().delegate = self
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        return true
    }
    
    func registerForLocalNotifications() {
        let center = UNUserNotificationCenter.current()
        
        center.delegate = self
        
        center.requestAuthorization(options: [.sound, .alert, .badge]) { granted, error in
            if granted {
            } else if let error = error {
                print("Notification authorization error: \(error.localizedDescription)")
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
        NotificationCenter.default.post(name: Notification.Name("ClearPath"), object: nil)
    }
}
