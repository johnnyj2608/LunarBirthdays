//
//  Birthdays.swift
//  Lunar Birthdays
//
//  Created by Johnny Jiang on 7/21/23.
//

import SwiftUI

struct Birthday: Identifiable {
    let id = UUID()
    let picture: String
    let name: String
    let date: String
    let countdown: Int
}

struct BirthdayList {
    
    static let topFive = [
        Birthday(picture: "wish-i-knew",
               name: "Johnny Jiang",
               date: "November 4, 2023",
               countdown: 10),
        
        Birthday(picture: "wish-i-knew",
               name: "Kai Jiang",
               date: "November 5, 2023",
               countdown: 21),
        
        Birthday(picture: "wish-i-knew",
               name: "Johnny Test",
               date: "November 6, 2023",
               countdown: 22),
        
        Birthday(picture: "wish-i-knew",
               name: "Johnny Cash",
               date: "November 7, 2023",
               countdown: 23),
        
        Birthday(picture: "wish-i-knew",
               name: "John Deere",
               date: "November 8, 2023",
               countdown: 24),
        
        Birthday(picture: "wish-i-knew",
               name: "John Deere",
               date: "November 8, 2023",
               countdown: 24),
        Birthday(picture: "wish-i-knew",
               name: "John Deere",
               date: "November 8, 2023",
               countdown: 24),
        Birthday(picture: "wish-i-knew",
               name: "John Deere",
               date: "November 8, 2023",
               countdown: 24),
        Birthday(picture: "wish-i-knew",
               name: "John Deere",
               date: "November 8, 2023",
               countdown: 24),
        Birthday(picture: "wish-i-knew",
               name: "John Deere",
               date: "November 8, 2023",
               countdown: 24),
        Birthday(picture: "wish-i-knew",
               name: "John Deere",
               date: "November 8, 2023",
               countdown: 24)
    ]
}
