//
//  SettingsView.swift
//  LunarBirthdays
//
//  Created by Johnny Jiang on 7/23/23.
//

import SwiftUI
import UserNotifications

struct SettingsView: View {
    
    @AppStorage("notifications") private var notifications = false
    @AppStorage("notif_time") private var notif_time = "00:00"
    @State private var notif_date = Date()
    
    @AppStorage("notif_tomorrow") private var notif_tomorrow = true
    @AppStorage("notif_week") private var notif_week = true
    @AppStorage("notif_toggle") private var notif_toggle = false
    
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
                                    notif_toggle = true
                                } else {
                                    notifications = false
                                    showPermissionAlert = true
                                }
                            }
                        } else {
                            notif_toggle = false
                        }
                    }
                if notifications && notif_toggle {
                    DatePicker(
                        "Notification Time",
                        selection: $notif_date,
                        displayedComponents: [.hourAndMinute]
                    )
                    .onChange(of: notif_date) { newValue in
                        notif_time = timeFormatter.string(from: newValue)
                    }
                    Toggle("On Birthday at \(twelveFormatter.string(from: notif_date))", isOn: .constant(true))
                        .tint(Color.green.opacity(0.5))
                    Toggle("1 Day Before", isOn: $notif_tomorrow)
                    Toggle("1 Week Before", isOn: $notif_week)
                    // Schedule all notifications here
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
        .onAppear {
            if let dateFromTime = timeFormatter.date(from: notif_time) {
                notif_date = dateFromTime
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
    private var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    private var twelveFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
