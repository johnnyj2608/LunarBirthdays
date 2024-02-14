//
//  TimeFormatting.swift
//  LunarBirthdays
//
//  Created by Johnny Jiang on 7/23/23.
//

import Foundation

func nextBirthday(_ date: Date, _ lunar: Bool? = false) -> Date {
    let cal = Calendar.current
    let today = cal.startOfDay(for: Date())
    let birthday = cal.startOfDay(for: date)
    
    let components = cal.dateComponents([.day, .month], from: birthday)
    var nextDate = cal.nextDate(after: today, matching: components, matchingPolicy: .nextTimePreservingSmallerComponents)
    
    if lunar == true {
        let lastBirthday = cal.date(byAdding: .year, value: -1, to: nextDate!)
        if today <= convertLunarToGregorian(lastBirthday!) {
            nextDate = lastBirthday
        }
        nextDate = convertLunarToGregorian(nextDate!)
    }
    
    let birthdayComponents = cal.dateComponents([.month, .day], from: nextDate!)
    let todayComponents = cal.dateComponents([.month, .day], from: today)

    if birthdayComponents == todayComponents {
        return today
    }
    
    guard let nextDate = nextDate else {
            fatalError("Next birthday date calculation failed.")
        }
    return nextDate
}

func calcCountdown(_ date: Date, _ lunar: Bool? = false) -> (days: Int, hours: Int, mins: Int, secs: Int) {
    let cal = Calendar.current
    let today = cal.startOfDay(for: Date())
    var nextBirthday = cal.startOfDay(for: nextBirthday(date))
    if lunar == true {
        let lastBirthday = cal.date(byAdding: .year, value: -1, to: nextBirthday)!
        if today <= convertLunarToGregorian(lastBirthday) {
            nextBirthday = lastBirthday
        }
        nextBirthday = convertLunarToGregorian(nextBirthday)
    }
    
    if nextBirthday <= today {
        return (0, 0, 0, 0)
    }
    
    let components = cal.dateComponents([.day, .hour, .minute, .second], from: Date(), to: nextBirthday)
    
    guard let daysRemaining = components.day,
          let hoursRemaining = components.hour,
          let minutesRemaining = components.minute,
          let secondsRemaining = components.second else {
        return (0, 0, 0, 0)
    }
    
    return (daysRemaining, hoursRemaining, minutesRemaining, secondsRemaining)
}

func calcAge(_ date: Date, _ lunar: Bool? = false) -> Int {
    let cal = Calendar.current
    let birthday = cal.startOfDay(for: date)
    let today = cal.startOfDay(for: Date())
    var nextBirthday = nextBirthday(date)
    if lunar == true {
        let lastBirthday = cal.date(byAdding: .year, value: -1, to: nextBirthday)!
        if today <= convertLunarToGregorian(lastBirthday) {
            nextBirthday = lastBirthday
        }
        nextBirthday = convertLunarToGregorian(nextBirthday)
    }
    nextBirthday = cal.startOfDay(for: nextBirthday)
    let ageComponents = cal.dateComponents([.year], from: birthday, to: nextBirthday)
    
    guard let age = ageComponents.year else {
        return -1
    }
    if lunar == true {
        return age + 1
    }
    return age
}

func getDay(_ date: Date?, _ lunar: Bool? = false) -> Int {
    let cal = Calendar.current
    guard let date = date else { return 1 }
    let today = cal.startOfDay(for: Date())
    var nextBirthday = nextBirthday(date)
    if lunar == true {
        let lastBirthday = cal.date(byAdding: .year, value: -1, to: nextBirthday)!
        if today <= convertLunarToGregorian(lastBirthday) {
            nextBirthday = lastBirthday
        }
        nextBirthday = convertLunarToGregorian(nextBirthday)
    }
    return cal.component(.day, from: nextBirthday)
}

func getMonth(_ date: Date?, _ lunar: Bool? = false) -> Int {
    let cal = Calendar.current
    guard let date = date else { return 1 }
    let today = cal.startOfDay(for: Date())
    var nextBirthday = nextBirthday(date)
    if lunar == true {
        let lastBirthday = cal.date(byAdding: .year, value: -1, to: nextBirthday)!
        if today <= convertLunarToGregorian(lastBirthday) {
            nextBirthday = lastBirthday
        }
        nextBirthday = convertLunarToGregorian(nextBirthday)
    }
    return cal.component(.month, from: nextBirthday)
}

func getYear(_ date: Date?, _ lunar: Bool? = false) -> Int {
    let cal = Calendar.current
    guard let date = date else { return 1 }
    let today = cal.startOfDay(for: Date())
    var nextBirthday = date
    if lunar == true {
        let lastBirthday = cal.date(byAdding: .year, value: -1, to: nextBirthday)!
        if today <= convertLunarToGregorian(lastBirthday) {
            nextBirthday = lastBirthday
        }
        nextBirthday = convertLunarToGregorian(nextBirthday)
    }
    return cal.component(.year, from: nextBirthday)
}

func monthString(_ month: Int) -> String {
    let dateFormatter = DateFormatter()
    
    dateFormatter.dateFormat = "MMMM"
    if let firstLanguage = Locale.preferredLanguages.first {
        if firstLanguage.hasPrefix("zh") {
            dateFormatter.dateFormat = "M"
        }
    }
    
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

func nextLunarBirthday(_ birthday: Date, _ lunar: Bool) -> String {
    let cal = Calendar.current
    let birthday = cal.startOfDay(for: birthday)
    let today = cal.startOfDay(for: Date())
    var nextBirthday = nextBirthday(birthday)
    var dateToConvert = Date()
    
    if lunar {
        let lastBirthday = cal.date(byAdding: .year, value: -1, to: nextBirthday)!
        if today <= convertLunarToGregorian(lastBirthday) {
            nextBirthday = lastBirthday
        }
        dateToConvert = convertLunarToGregorian(nextBirthday)
    } else {
        let nextYear = cal.date(byAdding: .year, value: 1, to: nextBirthday)!
        if today > convertGregorianToLunar(nextBirthday) {
            nextBirthday = nextYear
        }
        dateToConvert = convertGregorianToLunar(nextBirthday)
    }
    
    let month = monthString(getMonth(dateToConvert))
    let day = dayString(getDay(dateToConvert))
    let year = yearString(getYear(dateToConvert))
    
    let dateString = String.localizedStringWithFormat(NSLocalizedString("Full-Date %@ %@ %@", comment: ""), month, day, year)
    return dateString
}
