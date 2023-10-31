//
//  LunarConverter.swift
//  LunarBirthdays
//
//  Created by Johnny Jiang on 8/24/23.
//

import Foundation

func lunarConverter(_ birthday: Date) -> Date {
    let g_year = Calendar.current.component(.year, from: birthday)
    let g_adj_year = g_year + 2697

    let c_era = Int(g_adj_year / 60)
    let c_year = g_adj_year - c_era * 60

    var components = DateComponents()
    components.era = c_era
    components.year = c_year
    components.month = Calendar.current.component(.month, from: birthday)
    components.day = Calendar.current.component(.day, from: birthday)

    let chineseCalendar = Calendar(identifier: .chinese)
    let c_ny = chineseCalendar.date(from: components)!

    return c_ny
}

func gregorianConverter(_ birthday: Date) -> Date {
    let chineseCalendar = Calendar(identifier: .chinese)

    let c_era = chineseCalendar.component(.era, from: birthday)
    let c_year = chineseCalendar.component(.year, from: birthday)
    let c_month = chineseCalendar.component(.month, from: birthday)
    let c_day = chineseCalendar.component(.day, from: birthday)

    let g_adj_year = c_era * 60 + c_year - 2697

    var components = DateComponents()
    components.year = g_adj_year
    components.month = c_month
    components.day = c_day

    let gregorianCalendar = Calendar(identifier: .gregorian)
    let gregorianDate = gregorianCalendar.date(from: components)!

    return gregorianDate
}

func getZodiac(_ birthday: Date, _ lunar: Bool) -> String {
    var year = birthday
    if lunar == false {
        year = gregorianConverter(year)
    }
    let zodiac = getYear(year)
    switch zodiac % 12 {
        case 0:
            return "🐒" // Monkey
        case 1:
            return "🐓" // Rooster
        case 2:
            return "🐕" // Dog
        case 3:
            return "🐖" // Pig
        case 4:
            return "🐀" // Rat
        case 5:
            return "🐂" // Ox
        case 6:
            return "🐅" // Tiger
        case 7:
            return "🐇" // Rabbit
        case 8:
            return "🐉" // Dragon
        case 9:
            return "🐍" // Snake
        case 10:
            return "🐎" // Horse
        case 11:
            return "🐐" // Goat
        default:
            return "❓"
    }
}
