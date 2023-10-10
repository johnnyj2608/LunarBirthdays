//
//  TimeFormatting.swift
//  LunarBirthdays
//
//  Created by Johnny Jiang on 7/23/23.
//

import Foundation

func nextBirthday(_ date: Date) -> Date {
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
    return unwrappedNextDate
}

func calcCountdown(_ date: Date, calendar: String? = nil) -> (days: Int, hours: Int, mins: Int, secs: Int) {
    let cal = Calendar.current
    let today = Date()
    var nextBirthday = cal.startOfDay(for: nextBirthday(date))
    if calendar == "Lunar" {
        nextBirthday = lunarConverter(nextBirthday)
    }
    
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

func calcAge(_ date: Date, calendar: String? = nil) -> Int {
    let cal = Calendar.current
    let birthday = cal.startOfDay(for: date)
    var nextBirthdayDate = nextBirthday(date)
    if calendar == "Lunar" {
        nextBirthdayDate = lunarConverter(nextBirthdayDate)
    }
    let nextBirthday = cal.startOfDay(for: nextBirthdayDate)
    let ageComponents = cal.dateComponents([.year], from: birthday, to: nextBirthday)
    
    guard let age = ageComponents.year else {
        return -1
    }
    if calendar == "Lunar" {
        return age + 1
    }
    return age
}

func getDay(_ date: Date?, calendar: String? = nil) -> Int {
    let cal = Calendar.current
    guard let date = date else { return 1 }
    var next = nextBirthday(date)
    if calendar == "Lunar" {
        next = lunarConverter(next)
    }
    return cal.component(.day, from: next)
}

func getMonth(_ date: Date?, calendar: String? = nil) -> Int {
    let cal = Calendar.current
    guard let date = date else { return 1 }
    var next = nextBirthday(date)
    if calendar == "Lunar" {
        next = lunarConverter(next)
    }
    return cal.component(.month, from: next)
}

func getYear(_ date: Date?, calendar: String? = nil) -> Int {
    let cal = Calendar.current
    guard let date = date else { return 1 }
    var next = date
    if calendar == "Lunar" {
        next = lunarConverter(next)
    }
    return cal.component(.year, from: next)
}

func getNextYear(_ date: Date?, calendar: String? = nil) -> Int {
    let cal = Calendar.current
    guard let date = date else { return 1 }
    var next = nextBirthday(date)
    if calendar == "Lunar" {
        next = lunarConverter(next)
    }
    return cal.component(.year, from: next)
}

func monthString(_ month: Int) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM"
    let date = Calendar.current.date(from: DateComponents(month: month))!
    return dateFormatter.string(from: date)
}

func dayString(_ day: Int) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "d"
    let date = Calendar.current.date(from: DateComponents(day: day))!
    return dateFormatter.string(from: date)
}

func yearString(_ year: Int) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy"
    let date = Calendar.current.date(from: DateComponents(year: year))!
    return dateFormatter.string(from: date)
}

func dateString(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM d, yyyy"
    return dateFormatter.string(from: date)
}
