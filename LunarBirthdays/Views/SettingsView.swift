//
//  SettingsView.swift
//  LunarBirthdays
//
//  Created by Johnny Jiang on 7/23/23.
//

import SwiftUI
import CoreData
import UserNotifications

struct SettingsView: View {
    
    @Environment(\.managedObjectContext) var managedObjContext
    @FetchRequest(sortDescriptors: []) var birthday: FetchedResults<Birthday>
    
    @AppStorage("notifications") private var notifications = false
    @AppStorage("notif_time") private var notif_time = "00:00"
    @State private var notif_date = Date()
    
    @AppStorage("notif_tomorrow") private var notif_day = true
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
                                    scheduleAllBirthdays(offset: 0)
                                    if notif_day {
                                        scheduleAllBirthdays(offset: 1)
                                    }
                                    if notif_week {
                                        scheduleAllBirthdays(offset: 7)
                                    }
                                } else {
                                    notifications = false
                                    showPermissionAlert = true
                                }
                            }
                        } else {
                            notif_toggle = false
                            cancelAllBirthdays(offset: 0)
                            cancelAllBirthdays(offset: 1)
                            cancelAllBirthdays(offset: 7)
                        }
                        // Cancel notification on birthday
                    }
                if notifications && notif_toggle {
                    DatePicker(
                        "Notification Time",
                        selection: $notif_date,
                        displayedComponents: [.hourAndMinute]
                    )
                    .onChange(of: notif_date) { newValue in
                        notif_time = timeFormatter.string(from: newValue)
                        cancelAllBirthdays(offset: 0)
                        cancelAllBirthdays(offset: 1)
                        cancelAllBirthdays(offset: 7)
                        
                        scheduleAllBirthdays(offset: 0)
                        if notif_day {
                            scheduleAllBirthdays(offset: 1)
                        }
                        if notif_week {
                            scheduleAllBirthdays(offset: 7)
                        }
                    }
                    Toggle("On Birthday at \(twelveFormatter.string(from: notif_date))", isOn: .constant(true))
                        .tint(Color.green.opacity(0.5))
                    Toggle("1 Day Before", isOn: $notif_day)
                        .onChange(of: notif_day) { newValue in
                            if newValue {
                                scheduleAllBirthdays(offset: 1)
                            } else {
                                cancelAllBirthdays(offset: 1)
                            }
                        }
                    Toggle("1 Week Before", isOn: $notif_week)
                        .onChange(of: notif_week) { newValue in
                            if newValue {
                                scheduleAllBirthdays(offset: 7)
                            } else {
                                cancelAllBirthdays(offset: 7)
                            }
                        }
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
    private func scheduleAllBirthdays(offset: Int = 0) {
        for bday in birthday {
            Notifications.scheduleBirthday(bday, offset: offset)
        }
    }
    private func cancelAllBirthdays(offset: Int = 0) {
        for bday in birthday {
            Notifications.cancelBirthday(bday, offset: offset)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
