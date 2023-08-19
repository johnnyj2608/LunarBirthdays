//
//  DataController.swift
//  LunarBirthdays
//
//  Created by Johnny Jiang on 7/22/23.
//

import Foundation
import CoreData
import PhotosUI

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
    func addBirthday(img: String, name: String, date: Date, note: String, cal: String, context: NSManagedObjectContext) {
        let birthday = Birthday(context: context)
        birthday.id = UUID()
        birthday.img = img
        birthday.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        birthday.date = date
        birthday.note = note.trimmingCharacters(in: .whitespacesAndNewlines)
        birthday.cal = cal
        
        save(context: context)
        
        if UserDefaults.standard.bool(forKey: "notifications") {
            Notifications.scheduleBirthday(birthday, offset: 0)
        }
        if UserDefaults.standard.bool(forKey: "notif_day") {
            Notifications.scheduleBirthday(birthday, offset: 1)
        }
        if UserDefaults.standard.bool(forKey: "notif_week") {
            Notifications.scheduleBirthday(birthday, offset: 7)
        }
    }
    func editBirthday(birthday: Birthday, img: String, name: String, date: Date, note: String, cal: String, context: NSManagedObjectContext) {
        birthday.img = img
        birthday.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        birthday.date = date
        birthday.note = note.trimmingCharacters(in: .whitespacesAndNewlines)
        birthday.cal = cal
        
        save(context: context)

        if UserDefaults.standard.bool(forKey: "notifications") {
            Notifications.cancelBirthday(birthday, offset: 0)
            Notifications.scheduleBirthday(birthday, offset: 0)
        }
        if UserDefaults.standard.bool(forKey: "notif_day") {
            Notifications.cancelBirthday(birthday, offset: 1)
            Notifications.scheduleBirthday(birthday, offset: 1)
        }
        if UserDefaults.standard.bool(forKey: "notif_week") {
            Notifications.cancelBirthday(birthday, offset: 7)
            Notifications.scheduleBirthday(birthday, offset: 7)
        }
    }
    func deleteBirthday(birthday: Birthday, context: NSManagedObjectContext) {
        context.delete(birthday)
        save(context: context)
    }
    
    func saveImage(_ image: UIImage, withFilename filename: String) -> String? {
        if let data = image.jpegData(compressionQuality: 0.8) {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let fileURL = paths[0].appendingPathComponent(filename)
            do {
                try data.write(to: fileURL)
                return fileURL.path
            } catch {
                print("Failed to save image: \(error)")
            }
        }
        return nil
    }
    
    func clearDocumentsDirectory() {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!

        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil, options: [])
            
            for fileURL in fileURLs {
                try fileManager.removeItem(at: fileURL)
            }
        } catch {
            print("Error clearing Documents directory: \(error)")
        }
    }

}
