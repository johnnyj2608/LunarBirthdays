//
//  DataController.swift
//  LunarBirthdays
//
//  Created by Johnny Jiang on 7/22/23.
//

import Foundation
import CoreData

class DataController: ObservableObject {
    
    let container = NSPersistentContainer(name: "BirthdayModel")
    
    
    init() {
        container.loadPersistentStores { desc, error in
            if let error = error {
                print("Failed to load data \(error.localizedDescription)")
            } else {
                print("Data loaded")
            }
        }
    }
    
    func save(context: NSManagedObjectContext) {
        do {
            try context.save()
            print("Data saved")
        } catch {
            print("Failed to save data")
        }
    }
    func addBirthday(img: Data, name: String, date: Date, note: String, cal: String, context: NSManagedObjectContext) {
        let birthday = Birthday(context: context)
        birthday.id = UUID()
        birthday.img = img
        birthday.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        birthday.date = date
        birthday.note = note.trimmingCharacters(in: .whitespacesAndNewlines)
        birthday.cal = cal
        
        save(context: context)
    }
    func editBirthday(birthday: Birthday, img: Data, name: String, date: Date, note: String, cal: String, context: NSManagedObjectContext) {
        birthday.img = img
        birthday.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        birthday.date = date
        birthday.note = note.trimmingCharacters(in: .whitespacesAndNewlines)
        birthday.cal = cal
        
        save(context: context)
    }
    func deleteBirthday(birthday: Birthday, context: NSManagedObjectContext) {
        context.delete(birthday)
        save(context: context)
    }
}
