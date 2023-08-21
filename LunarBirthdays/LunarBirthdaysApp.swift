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
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        registerForLocalNotifications() 
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
}




