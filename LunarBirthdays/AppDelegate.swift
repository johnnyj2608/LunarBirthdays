//
//  AppDelegate.swift
//  LunarBirthdays
//
//  Created by Johnny Jiang on 9/28/23.
//

import SwiftUI
import GoogleMobileAds
import UserNotifications
//import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        registerForLocalNotifications()
        UNUserNotificationCenter.current().delegate = self
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        //let gIdConfiguration = GIDConfiguration(clientID: "602901638701-2hd6247vgkmeoe8629pmvmk1nvudkkoc.apps.googleusercontent.com", serverClientID: "602901638701-mpv6hkjaau5li8288dk60tqpcrqcuqlp.apps.googleusercontent.com")

        //GIDSignIn.sharedInstance.configuration = gIdConfiguration
        return true
    }
    
    func registerForLocalNotifications() {
        let center = UNUserNotificationCenter.current()
        
        center.delegate = self
        
        center.requestAuthorization(options: [.sound, .alert, .badge]) { granted, error in
            if granted {
                // Handle notification authorization
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
