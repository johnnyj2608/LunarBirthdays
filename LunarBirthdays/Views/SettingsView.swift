//
//  SettingsView.swift
//  LunarBirthdays
//
//  Created by Johnny Jiang on 7/23/23.
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage("darkMode") private var darkMode = true
    
    var body: some View {
        Form {
            Section(header: Text("Upgrade")) {
                Text("Birthday Reminder Pro")
                // Popup sheet
            }
            Section(header: Text("Notificaitons")) {
                Text("When Bro")
            }
            Section(header: Text("Default Calendar")) {
                Text("Lunar")
            }
            Section(header: Text("Export")) {
                Text("Google Calendar")
            }
            Section(header: Text("Appearance")) {
                Toggle("Dark Mode", isOn: $darkMode)
            }
            Section(header: Text("Feedback")) {
                Text("Rate this app")
            }
        }
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
