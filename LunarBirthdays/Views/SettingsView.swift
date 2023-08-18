//
//  SettingsView.swift
//  LunarBirthdays
//
//  Created by Johnny Jiang on 7/23/23.
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage("notifications") private var notifications = false
    
    @AppStorage("darkMode") private var darkMode = true
    @AppStorage("calendar") private var calendar = "Lunar"
    let calendars = ["Lunar", "Gregorian"]
    
    @State private var showPermissionAlert = false
    
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
                            getNotificationPermission { isAuthorized in
                                if isAuthorized {
                                    notifications = true
                                } else {
                                    notifications = false
                                    showPermissionAlert = true
                                }
                            }
                        } else {
                            notifications = newValue
                        }
                    }
                // Notifications for birthday, 1 day before, 1 week before
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
                Text("Tell a friend")
            }
            .alert(isPresented: $showPermissionAlert) {
                Alert(
                    title: Text("Notification Permission"),
                    message: Text("Please go to the notification settings and enable notifications for this app."),
                    primaryButton: .default(Text("Settings"), action: {
                        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
                        UIApplication.shared.open(settingsURL)
                    }),
                    secondaryButton: .cancel()
                )
            }
        }
        .navigationTitle("Settings")
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            getNotificationPermission { isAuthorized in
                if !isAuthorized {
                    notifications = false
                }
            }
        }
    }
    private func getNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
