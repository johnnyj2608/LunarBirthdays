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
        let notificationDate = calcNotification(birthday: birthday.date!, offset: offset, cal: birthday.cal!)
        
        let content = UNMutableNotificationContent()
        content.title = "Lunar Birthdays"
        if offset == 0 {
            content.body = "\(birthday.name ?? "")'s birthday is today!"
        } else {
            let days = offset == 1 ? "day" : "days"
            content.body = "\(birthday.name ?? "")'s birthday is in \(offset) \(days)!"
        }
        
        content.badge = NSNumber (value: 1)
        content.sound = UNNotificationSound.default
        
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
    
    static func calcNotification(birthday: Date, offset: Int, cal: String) -> Date {
        let notificationOffset: TimeInterval = TimeInterval(-offset) * 24 * 60 * 60
        var newBirthday = nextBirthday(birthday)
        
        if cal == "Gregorian" {
            
        } else if cal == "Lunar" {
            newBirthday = lunarConverter(newBirthday)
        } else {
            fatalError("Unsupported calendar type: \(cal)")
        }
        return newBirthday.addingTimeInterval(notificationOffset)
    }
}
