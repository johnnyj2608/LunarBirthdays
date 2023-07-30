//
//  TimeFormatting.swift
//  LunarBirthdays
//
//  Created by Johnny Jiang on 7/23/23.
//

import Foundation

func nextBirthday(date: Date) -> Date {
    let cal = Calendar.current
    let today = cal.startOfDay(for: Date())
    let birthday = cal.startOfDay(for: date)
    
    let birthdayComponents = cal.dateComponents([.month, .day], from: birthday)
    let todayComponents = cal.dateComponents([.month, .day], from: today)

    if birthdayComponents == todayComponents {
        return today
    }
    
    let components = cal.dateComponents([.day, .month], from: birthday)
    let nextDate = cal.nextDate(after: today, matching: components, matchingPolicy: .nextTimePreservingSmallerComponents)
    
    guard let unwrappedNextDate = nextDate else {
            fatalError("Next birthday date calculation failed.")
        }
    print(today)
    print(birthday)
    return unwrappedNextDate
}

func calcCountdown(date: Date) -> (days: Int, hours: Int, mins: Int, secs: Int) {
    let cal = Calendar.current
    let today = Date()
    let nextBirthday = cal.startOfDay(for: nextBirthday(date: date))
    
    if nextBirthday <= today {
        return (0, 0, 0, 0)
    }
    
    let components = cal.dateComponents([.day, .hour, .minute, .second], from: today, to: nextBirthday)
    
    guard let daysRemaining = components.day,
          let hoursRemaining = components.hour,
          let minutesRemaining = components.minute,
          let secondsRemaining = components.second else {
        return (0, 0, 0, 0)
    }
    
    return (daysRemaining, hoursRemaining, minutesRemaining, secondsRemaining)
}

func calcAge(date: Date) -> Int {
    let cal = Calendar.current
    let birthday = cal.startOfDay(for: date)
    let nextBirthdayDate = nextBirthday(date: date)
    let nextBirthday = cal.startOfDay(for: nextBirthdayDate)
    let ageComponents = cal.dateComponents([.year], from: birthday, to: nextBirthday)
    
    guard let age = ageComponents.year else {
        return -1
    }
    return age
}

func getDay(date: Date?) -> Int {
    let cal = Calendar.current
    guard let date = date else { return 1 }
    return cal.component(.day, from: date)
}

func getMonth(date: Date?) -> Int {
    let cal = Calendar.current
    guard let date = date else { return 1 }
    return cal.component(.month, from: date)
}

func getYear(date: Date?) -> Int {
    let cal = Calendar.current
    guard let date = date else { return 1 }
    return cal.component(.year, from: date)
}

func monthString(month: Int) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM"
    let date = Calendar.current.date(from: DateComponents(month: month))!
    return dateFormatter.string(from: date)
}

func dayString(day: Int) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd"
    let date = Calendar.current.date(from: DateComponents(day: day))!
    return dateFormatter.string(from: date)
}

func yearString(year: Int) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy"
    let date = Calendar.current.date(from: DateComponents(year: year))!
    return dateFormatter.string(from: date)
}

func dateString(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM dd, yyyy"
    return dateFormatter.string(from: date)
}
