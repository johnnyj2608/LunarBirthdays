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
               date: "November 4, 1999",
               countdown: 10),
        
        Birthday(picture: "wish-i-knew",
               name: "Kai Jiang",
               date: "Oct 19, 1997",
               countdown: 21)
        
    ]
}
