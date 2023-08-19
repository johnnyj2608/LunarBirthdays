//
//  Notifications.swift
//  LunarBirthdays
//
//  Created by Johnny Jiang on 8/17/23.
//

import Foundation
import UserNotifications

class Notifications {
    
    static func scheduleBirthday(_ birthday: Birthday, offset: Int = 0) {
        let notificationDate = calculateNotificationDate(birthday: birthday.date!, offset: offset)
        
        let content = UNMutableNotificationContent()
        content.title = "Birthday Reminder"
        content.body = "\(birthday.name ?? "")'s birthday is coming up!"
        
        var triggerDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"

        if let notifTime = UserDefaults.standard.string(forKey: "notif_time"),
           let timeComponents = timeFormatter.date(from: notifTime) {
            triggerDateComponents.hour = Calendar.current.component(.hour, from: timeComponents)
            triggerDateComponents.minute = Calendar.current.component(.minute, from: timeComponents)
        }
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: "\(birthday.id!)_\(offset)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    static func cancelBirthday(_ birthday: Birthday, offset: Int = 0) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["\(birthday.id!)_\(offset)"])
    }
    
    static func calculateNotificationDate(birthday: Date, offset: Int) -> Date {
        let notificationOffset: TimeInterval = TimeInterval(-offset) * 24 * 60 * 60
        return birthday.addingTimeInterval(notificationOffset)
    }
}
