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
