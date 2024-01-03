//
//  TestingData.swift
//  LunarBirthdays
//
//  Created by Johnny Jiang on 10/8/23.
//

import SwiftUI
import CoreData

func populateCoreData(managedObjContext: NSManagedObjectContext) {
    DataController.shared.deleteAllBirthdays()
    
    let calendar = Calendar.current
    let sampleData: [(img: UIImage, name: String, date: Date, note: String, lunar: Bool)] = [
        (UIImage(), "Asian Jim", calendar.date(from: DateComponents(year: 1978, month: 10, day: 1))!, "", true),
        (UIImage(), "Jim Halpert", calendar.date(from: DateComponents(year: 1978, month: 10, day: 1))!, "", false),
        (UIImage(), "Michael Scott", calendar.date(from: DateComponents(year: 1965, month: 3, day: 15))!, "", false),
        (UIImage(), "Pam Beesly", calendar.date(from: DateComponents(year: 1979, month: 3, day: 25))!, "", false),
        (UIImage(), "Dwight Schrute", calendar.date(from: DateComponents(year: 1970, month: 1, day: 20))!, "", false),
    ]
    
    for data in sampleData {
        DataController.shared.addBirthday(img: data.img, name: data.name, date: data.date, note: data.note, lunar: data.lunar, context: managedObjContext)
    }
}
