//
//  AppleCalendar.swift
//  LunarBirthdays
//
//  Created by Johnny Jiang on 9/24/23.
//

import SwiftUI
import EventKit

func exportBirthdays(_ birthdays: [Birthday], _ repeatYears: Double, progress: @escaping (CGFloat) -> Void, completion: @escaping () -> Void) {
    deleteCalendar()
    let eventStore = EKEventStore()
    let appCalendar = appCalendar()
    let calendar = Calendar.current
    
    let recurrence = Int(round(repeatYears))
    let totalEvents = birthdays.count * recurrence
    var eventsSaved = 0
    
    eventStore.requestAccess(to: .event) { (granted, error) in
        if granted && error == nil {
            for birthday in birthdays {
                for year in 0..<recurrence {
                    if var date = birthday.date {
                        date = nextBirthday(date)
                        if let modifiedDate = calendar.date(byAdding: .year, value: year, to: date) {
                            date = modifiedDate
                        }
                        if birthday.cal == "Lunar" {
                            date = lunarConverter(date)
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
        } else {
            print("Access to calendar denied")
            completion()
        }
    }
}

func appCalendar() -> EKCalendar? {
    let eventStore = EKEventStore()
    let name = "Lunar Birthdays"
    
    for calendar in eventStore.calendars(for: .event) {
        if calendar.title == name {
            calendar.cgColor = UIColor.red.cgColor
            do {
                try eventStore.saveCalendar(calendar, commit: true)
                return calendar
            } catch {
                print("Error updating calendar: \(error.localizedDescription)")
                return nil
            }
        }
    }
    
    let calendar = EKCalendar(for: .event, eventStore: eventStore)
    calendar.title = name
    calendar.cgColor = UIColor.red.cgColor
    
    guard let source = eventStore.defaultCalendarForNewEvents?.source else {
        return nil
    }
    calendar.source = source
    do {
        try eventStore.saveCalendar(calendar, commit: true)
        print("Success creating calendar!")
        return calendar
    } catch {
        print("Error creating calendar: \(error.localizedDescription)")
        return nil
    }
}

func deleteCalendar() {
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
            return
        }
    }
    print("Calendar with name '\(name)' not found.")
}
