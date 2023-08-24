//
//  LunarBirthdaysApp.swift
//  LunarBirthdays
//
//  Created by Johnny Jiang on 7/23/23.
//

import SwiftUI

@main
struct LunarBirthdaysApp: App {
    @StateObject private var dataController = DataController()
    @AppStorage("darkMode") private var darkMode = true
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .preferredColorScheme(darkMode ? .dark : .light)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    UIApplication.shared.applicationIconBadgeNumber = 0
                    UserDefaults.standard.set(0, forKey: "badges")
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                    UIApplication.shared.applicationIconBadgeNumber = 0
                    UserDefaults.standard.set(0, forKey: "badges")
                }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    @AppStorage("badges") private var badges = 0
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        registerForLocalNotifications()
        UNUserNotificationCenter.current().delegate = self
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
    }
}
