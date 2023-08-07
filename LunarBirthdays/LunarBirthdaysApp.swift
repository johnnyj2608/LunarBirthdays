//
//  LunarBirthdaysApp.swift
//  LunarBirthdays
//
//  Created by Johnny Jiang on 7/23/23.
//

import SwiftUI

@main
struct LunarBirthdaysApp: App {
    @StateObject private var dataController = DataController()
    @AppStorage("darkMode") private var darkMode = true
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .preferredColorScheme(darkMode ? .dark : .light)
        }
    }
}
