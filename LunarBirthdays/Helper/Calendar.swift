//
//  Calendar.swift
//  LunarBirthdays
//
//  Created by Johnny Jiang on 9/24/23.
//

import Foundation
import EventKit

func exportBirthdays(_ birthdays: [Birthday], completion: @escaping () -> Void) {
    deportBirthdays(birthdays) {
        let eventStore = EKEventStore()
        eventStore.requestAccess(to: .event) { (granted, error) in
            if granted && error == nil {
                for birthday in birthdays {
                    if var date = birthday.date {
                        date = nextBirthday(date)
                        if birthday.cal == "Lunar" {
                            date = lunarConverter(date)
                        }
                        let event = EKEvent(eventStore: eventStore)
                        event.calendar = eventStore.defaultCalendarForNewEvents
                        event.title = "Birthday: \(birthday.name ?? "")"
                        event.startDate = date
                        event.endDate = date
                        event.isAllDay = true
                        
                        let recurrenceRule = EKRecurrenceRule(
                            recurrenceWith: .yearly,
                            interval: 1,
                            daysOfTheWeek: nil,
                            daysOfTheMonth: nil,
                            monthsOfTheYear: nil,
                            weeksOfTheYear: nil,
                            daysOfTheYear: nil,
                            setPositions: nil,
                            end: nil
                        )
                        event.recurrenceRules = [recurrenceRule]
                        
                        do {
                            try eventStore.save(event, span: .thisEvent)
                            print("Saved event for \(birthday.name ?? "")'s birthday.")
                        } catch {
                            print("Error saving event to calendar: \(error.localizedDescription)")
                        }
                    }
                }
                completion()
            } else {
                print("Access to calendar denied")
                completion()
            }
        }
    }
}

func deportBirthdays(_ birthdays: [Birthday], completion: @escaping () -> Void) {
    let eventStore = EKEventStore()
    eventStore.requestAccess(to: .event) { (granted, error) in
        if granted && error == nil {
            for birthday in birthdays {
                if var date = birthday.date {
                    date = nextBirthday(date)
                    if birthday.cal == "Lunar" {
                        date = lunarConverter(date)
                    }
                    let endDate = date.addingTimeInterval(86400)
                    let predicate = eventStore.predicateForEvents(withStart: date, end: endDate, calendars: nil)
                    let events = eventStore.events(matching: predicate)
                    for event in events {
                        if event.title == "Birthday: \(birthday.name ?? "")" {
                            do {
                                try eventStore.remove(event, span: .thisEvent)
                                print("Deleted event for \(birthday.name ?? "")'s birthday.")
                            } catch {
                                print("Error deleting event for \(birthday.name ?? "")'s birthday: \(error.localizedDescription)")
                            }
                        }
                    }
                }
            }
            completion()
        } else {
            print("Access to calendar denied")
            completion()
        }
    }
}
