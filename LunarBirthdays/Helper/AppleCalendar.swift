//
//  AppleCalendar.swift
//  LunarBirthdays
//
//  Created by Johnny Jiang on 9/24/23.
//

import SwiftUI
import EventKit

func exportBirthdays(_ birthdays: [Birthday], _ repeatYears: Double, progress: @escaping (CGFloat) -> Void, completion: @escaping () -> Void) {
    let eventStore = EKEventStore()
    let calendar = Calendar.current
    
    let recurrence = Int(round(repeatYears))
    let totalEvents = birthdays.count * recurrence
    var eventsSaved = 0
    
    eventStore.requestAccess(to: .event) { (granted, error) in
        if granted && error == nil {
            deleteCalendar{
                addCalendar { appCalendar in
                    guard let appCalendar = appCalendar else {
                        print("Error creating or retrieving the calendar.")
                        completion()
                        return
                    }
                    for birthday in birthdays {
                        for year in 0..<recurrence {
                            if var date = birthday.date {
                                date = nextBirthday(date, birthday.lunar)
                                if let modifiedDate = calendar.date(byAdding: .year, value: year, to: date) {
                                    date = modifiedDate
                                }
                                let event = EKEvent(eventStore: eventStore)
                                event.calendar = appCalendar
                                event.title = "\(birthday.name ?? "")'s birthday!"
                                event.startDate = date
                                event.endDate = date
                                event.notes = birthday.note ?? ""
                                event.isAllDay = true
                                event.alarms = nil
                                
                                do {
                                    try eventStore.save(event, span: .thisEvent)
                                    print("Saved event for \(birthday.name ?? "")'s birthday for \(date)")
                                    eventsSaved += 1
                                    let progressPercentage = CGFloat(eventsSaved) / CGFloat(totalEvents)
                                    progress(progressPercentage)
                                    if progressPercentage >= 1.0 {
                                        DispatchQueue.main.async {
                                            completion()
                                        }
                                    }
                                } catch {
                                    print("Error saving event to calendar: \(error.localizedDescription)")
                                    completion()
                                }
                            }
                        }
                    }
                    
                }
            }
        } else {
            print("Access to calendar denied")
            completion()
        }
    }
}

func addCalendar(completion: @escaping (EKCalendar?) -> Void) {
    let eventStore = EKEventStore()
    let name = "Lunar Birthdays"
    
    for calendar in eventStore.calendars(for: .event) {
        if calendar.title == name {
            calendar.cgColor = UIColor.red.cgColor
            do {
                try eventStore.saveCalendar(calendar, commit: true)
                completion(calendar)
                return
            } catch {
                print("Error updating calendar: \(error.localizedDescription)")
                completion(nil)
                return
            }
        }
    }
    let calendar = EKCalendar(for: .event, eventStore: eventStore)
    calendar.title = name
    calendar.cgColor = UIColor.red.cgColor
    
    guard let source = eventStore.defaultCalendarForNewEvents?.source else {
        completion(nil)
        return
    }
    calendar.source = source
    do {
        try eventStore.saveCalendar(calendar, commit: true)
        print("Success creating calendar!")
        completion(calendar)
    } catch {
        print("Error creating calendar: \(error.localizedDescription)")
        completion(nil)
    }
}

func deleteCalendar(completion: @escaping () -> Void) {
    let eventStore = EKEventStore()
    let name = "Lunar Birthdays"
    
    for calendar in eventStore.calendars(for: .event) {
        if calendar.title == name {
            do {
                try eventStore.removeCalendar(calendar, commit: true)
                print("Calendar deleted successfully.")
            } catch {
                print("Error deleting calendar: \(error.localizedDescription)")
            }
            completion()
            return
        }
    }
    print("Calendar with name '\(name)' not found.")
    completion()
}

func requestCalendarAccess(completion: @escaping (Bool) -> Void) {
    let eventStore = EKEventStore()
    eventStore.requestAccess(to: .event) { (granted, error) in
        if granted {
            completion(true)
        } else {
            completion(false)
            print("Access to calendar denied")
        }
    }
}

