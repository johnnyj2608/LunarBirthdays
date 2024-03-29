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
        let notificationDate = calcOffset(birthday.date!, offset, birthday.lunar)
        
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
        
        var calendar = Calendar(identifier: .gregorian)
        if birthday.lunar == true {
            calendar = Calendar(identifier: .chinese)
        }
        var components = calendar.dateComponents([.calendar, .month, .day, .hour, .minute], from: notificationDate)
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        if let notifTime = UserDefaults.standard.string(forKey: "notif_time"),
           let timeComponents = timeFormatter.date(from: notifTime) {
            components.hour = Calendar.current.component(.hour, from: timeComponents)
            components.minute = Calendar.current.component(.minute, from: timeComponents)
        }
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(identifier: "\(birthday.id!)_\(offset)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    static func cancelBirthday(_ birthday: Birthday, offset: Int = 0) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["\(birthday.id!)_\(offset)"])
    }
    
    static func cancelAllBirthdays() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    static func calcOffset(_ birthday: Date, _ offset: Int, _ lunar: Bool) -> Date {
        var notificationDate = birthday
        if lunar == true {
            notificationDate = convertLunarToGregorian(notificationDate)
        }
        let notificationOffset: TimeInterval = TimeInterval(-offset) * 24 * 60 * 60
        return notificationDate.addingTimeInterval(notificationOffset)
    }
}
