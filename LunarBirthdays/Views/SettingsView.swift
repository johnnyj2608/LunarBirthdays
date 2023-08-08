//
//  SettingsView.swift
//  LunarBirthdays
//
//  Created by Johnny Jiang on 7/23/23.
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage("notifications") private var notifications = false
    @AppStorage("notif_today") private var notif_today = true
    @AppStorage("notif_tomorrow") private var notif_tomorrow = true
    @AppStorage("notif_week") private var notif_week = true
    
    @AppStorage("darkMode") private var darkMode = true
    @AppStorage("calendar") private var calendar = "Lunar"
    let calendars = ["Lunar", "Gregorian"]
    
    var body: some View {
        Form {
            Section(header: Text("Upgrade")) {
                Text("Birthday Reminder Pro")
                // Popup sheet
            }
            Section(header: Text("Notifications")) {
                Toggle("Enable Notifications", isOn: $notifications)
                    .onChange(of: notifications) { newValue in
                        if newValue {
                            if getNotificationPermission() {
                                notifications.toggle()
                            } else {
                                // Send Alert
                            }
                        } else {
                            notifications = newValue
                        }
                    }
                
                if notifications {
                    Toggle("On Birthday", isOn: $notif_today)
                    Toggle("1 Day Before", isOn: $notif_tomorrow)
                    Toggle("1 Week Before", isOn: $notif_week)
                    // Notification Time
                }
            }
            Section(header: Text("Default Calendar")) {
                Picker("Calendar", selection: $calendar) {
                    ForEach(calendars, id: \.self) {
                        Text($0)
                    }
                }
            }
            Section(header: Text("Appearance")) {
                Toggle("Dark Mode", isOn: $darkMode)
            }
            Section(header: Text("Export")) {
                Text("Google Calendar")
                // OAuth Google
            }
            Section(header: Text("Feedback")) {
                Text("Rate this app")
                // Must wait until published
            }
        }
        .navigationTitle("Settings")
        .onAppear {
            notifications = getNotificationPermission()
        }
    }
    private func getNotificationPermission() -> Bool {
        var Authorization = false
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                Authorization = settings.authorizationStatus == .authorized
            }
        }
        return Authorization
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
