//
//  TimeFormatting.swift
//  LunarBirthdays
//
//  Created by Johnny Jiang on 7/23/23.
//

import Foundation

func calcCountdown(date: Date) -> Int {
    let cal = Calendar.current
    let today = cal.startOfDay(for: Date())
    let birthday = cal.startOfDay(for: date)
    let components = cal.dateComponents([.day, .month], from: birthday)
    let nextDate = cal.nextDate(after: today, matching: components, matchingPolicy: .nextTimePreservingSmallerComponents)
    return cal.dateComponents([.day], from: today, to: nextDate ?? today).day ?? 0
}

func nextBirthday(date: Date) -> String {
    let cal = Calendar.current
    let today = cal.startOfDay(for: Date())
    let birthday = cal.startOfDay(for: date)
    let components = cal.dateComponents([.day, .month], from: birthday)
    let nextDate = cal.nextDate(after: today, matching: components, matchingPolicy: .nextTimePreservingSmallerComponents)
    return dateString(date: nextDate!)
}

func dateString(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .long
    return dateFormatter.string(from: date)
}
