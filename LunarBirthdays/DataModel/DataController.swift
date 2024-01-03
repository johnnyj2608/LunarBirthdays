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
    
    static let shared = DataController()
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
    func addBirthday(img: UIImage, name: String, date: Date, note: String, lunar: Bool, context: NSManagedObjectContext) {
        let birthday = Birthday(context: context)
        birthday.id = UUID()
        
        if let imagePath = saveImage(img, withFilename: "\(birthday.id!).jpg") {
             birthday.img = imagePath
         }
        
        birthday.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        birthday.date = date
        birthday.note = note.trimmingCharacters(in: .whitespacesAndNewlines)
        birthday.lunar = lunar
         
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
    func editBirthday(birthday: Birthday, img: UIImage, name: String, date: Date, note: String, lunar: Bool, context: NSManagedObjectContext) {
        if let imagePath = saveImage(img, withFilename: "\(birthday.id!).jpg") {
             birthday.img = imagePath
         }
        
        birthday.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        birthday.date = date
        birthday.note = note.trimmingCharacters(in: .whitespacesAndNewlines)
        birthday.lunar = lunar
        
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
        if UserDefaults.standard.bool(forKey: "notifications") {
            Notifications.cancelBirthday(birthday, offset: 0)
        }
        if UserDefaults.standard.bool(forKey: "notif_day") {
            Notifications.cancelBirthday(birthday, offset: 1)
        }
        if UserDefaults.standard.bool(forKey: "notif_week") {
            Notifications.cancelBirthday(birthday, offset: 7)
        }
        context.delete(birthday)
        save(context: context)
    }
    
    func deleteAllBirthdays() {
        Notifications.cancelAllBirthdays()
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Birthday")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try container.viewContext.execute(batchDeleteRequest)
            try container.viewContext.save()
            print("All data deleted")
        } catch {
            print("Failed to delete all data: \(error)")
        }
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
    
    func loadImage(withFilename filename: String) -> UIImage? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let fileURL = paths[0].appendingPathComponent(filename)

        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                let imageData = try Data(contentsOf: fileURL)
                return UIImage(data: imageData)
            } catch {
                print("Failed to load image: \(error)")
            }
        }

        return nil
    }

    
    func countBirthdays() -> Int {
        let fetchRequest: NSFetchRequest<Birthday> = Birthday.fetchRequest()
        do {
            let count = try container.viewContext.count(for: fetchRequest)
            return count
        } catch {
            print("Failed to count birthdays: \(error)")
            return 0
        }
    }

}
