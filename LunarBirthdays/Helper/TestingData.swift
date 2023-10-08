//
//  TestingData.swift
//  LunarBirthdays
//
//  Created by Johnny Jiang on 10/8/23.
//

import SwiftUI
import CoreData

func populateCoreData(managedObjContext: NSManagedObjectContext) {
    
    let calendar = Calendar.current
    let sampleData: [(img: UIImage, name: String, date: Date, note: String, cal: String)] = [
        (UIImage(), "Asian Jim", calendar.date(from: DateComponents(year: 1978, month: 10, day: 1))!, "", "Lunar"),
        (UIImage(), "Jim Halpert", calendar.date(from: DateComponents(year: 1978, month: 10, day: 1))!, "", "Gregorian"),
        (UIImage(), "Michael Scott", calendar.date(from: DateComponents(year: 1965, month: 3, day: 15))!, "", "Gregorian"),
        (UIImage(), "Pam Beesly", calendar.date(from: DateComponents(year: 1979, month: 3, day: 25))!, "", "Gregorian"),
        (UIImage(), "Dwight Schrute", calendar.date(from: DateComponents(year: 1970, month: 1, day: 20))!, "", "Gregorian"),
    ]
    
    for data in sampleData {
        DataController.shared.addBirthday(img: data.img, name: data.name, date: data.date, note: data.note, cal: data.cal, context: managedObjContext)
    }
}
