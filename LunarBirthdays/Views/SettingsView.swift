//
//  SettingsView.swift
//  LunarBirthdays
//
//  Created by Johnny Jiang on 7/23/23.
//

import SwiftUI
import CoreData
import UserNotifications
import JGProgressHUD

struct SettingsView: View {
    
    @Environment(\.managedObjectContext) var managedObjContext
    @FetchRequest(sortDescriptors: []) var birthday: FetchedResults<Birthday>
    
    @AppStorage("notifications") private var notifications = false
    @AppStorage("notif_time") private var notif_time = "00:00"
    @State private var notif_date = Date()
    
    @AppStorage("notif_tomorrow") private var notif_day = false
    @AppStorage("notif_week") private var notif_week = false
    @AppStorage("notif_toggle") private var notif_toggle = false
    
    @AppStorage("darkMode") private var darkMode = true
    @AppStorage("calendar") private var calendar = "Lunar"
    let calendars = ["Lunar", "Gregorian"]
    
    @State private var showNotificationPermissionAlert = false
    @State private var showCalendarPermissionAlert = false
    @State private var showExportAlert = false
    @State private var showSignOutAlert = false
    @State private var showEmptyAlert = false
    @AppStorage("exportValue")  private var exportValue: Double = 50
    
    @State private var exportProgress: CGFloat = 0.0
    @State private var hud = JGProgressHUD()
    
    @StateObject var googleCalendar = GoogleCalendar()

    var body: some View {
        Form { /*
                Section(header: Text("Upgrade")) {
                Text("Birthday Reminder Pro")
                // Popup sheet
                } */
            Section(header: Text("Appearance")) {
                Toggle("Dark-Mode", isOn: $darkMode)
            }
            Section(header: Text("Notifications")) {
                Toggle("Enable-Notifications", isOn: $notifications)
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
                                    showNotificationPermissionAlert = true
                                }
                            }
                        } else {
                            notif_toggle = false
                            cancelAllBirthdays(offset: 0)
                            cancelAllBirthdays(offset: 1)
                            cancelAllBirthdays(offset: 7)
                        }
                    }
                if notifications && notif_toggle {
                    DatePicker(
                        "Notification-Time",
                        selection: $notif_date,
                        displayedComponents: [.hourAndMinute]
                    )
                    .onChange(of: notif_date) { newValue in
                        notif_time = timeFormatter.string(from: newValue)
                    }
                    .onChange(of: notif_time) { newValue in
                        cancelAllBirthdays(offset: 0)
                        cancelAllBirthdays(offset: 1)
                        cancelAllBirthdays(offset: 7)
                        
                        if notifications {
                            scheduleAllBirthdays(offset: 0)
                        }
                        if notif_day {
                            scheduleAllBirthdays(offset: 1)
                        }
                        if notif_week {
                            scheduleAllBirthdays(offset: 7)
                        }
                    }
                    Toggle("On-Birthday-At \(twelveFormatter.string(from: notif_date))", isOn: .constant(true))
                        .tint(Color.green.opacity(0.5))
                    Toggle("1-Day-Before", isOn: $notif_day)
                        .onChange(of: notif_day) { newValue in
                            if newValue {
                                scheduleAllBirthdays(offset: 1)
                            } else {
                                cancelAllBirthdays(offset: 1)
                            }
                        }
                    Toggle("1-Week-Before", isOn: $notif_week)
                        .onChange(of: notif_week) { newValue in
                            if newValue {
                                scheduleAllBirthdays(offset: 7)
                            } else {
                                cancelAllBirthdays(offset: 7)
                            }
                        }
                }
            }
            Section(header: Text("Calendar"), footer: Text("Export-99")) {
                Picker("Default", selection: $calendar) {
                    ForEach(calendars, id: \.self) { calendarType in
                        Text(LocalizedStringKey(calendarType))
                    }
                }
                Button(action: {
                    if DataController.shared.countBirthdays() == 0 {
                        showEmptyAlert = true
                        return
                    }
                    if googleCalendar.isSignedIn {
                        googleCalendar.showExportAlert = true
                    } else {
                        googleCalendar.signIn()
                    }
                }) {
                    Text("Export-To-Google-Cal")
                }
                Button(action: {
                    if DataController.shared.countBirthdays() == 0 {
                        showEmptyAlert = true
                        return
                    }
                    let calendarPermissionRequested = UserDefaults.standard.bool(forKey: "calendarPermissionRequested")
                    if calendarPermissionRequested {
                        requestCalendarAccess { granted in
                            if granted {
                                self.showExportAlert = true
                            } else {
                                showCalendarPermissionAlert = true
                            }
                        }
                    } else {
                        requestCalendarAccess { granted in
                            if granted {
                                self.showExportAlert = true
                            } else {
                            }
                            UserDefaults.standard.set(true, forKey: "calendarPermissionRequested")
                        }
                    }
                }) {
                    Text("Export-To-Apple-Cal")
                }
                VStack {
                    if exportValue == 1 {
                        Text("Export-Up-To: \(Int(exportValue))")
                    } else {
                        Text("Export-Up-To: \(Int(exportValue))s")
                    }
                    Slider(value: $exportValue, in: 1...99, step: 1)
                }
            }
            Section(header: Text("Feedback")) {
                Button(action: {
                    if let url = URL(string: "https://apps.apple.com/us/app/lunar-birthdays/id6468920519?action=write-review") {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }) {
                    Text("Rate-This-App")
                }
                ShareLink(item: URL(string: "https://apps.apple.com/us/app/lunar-birthdays/id6468920519")!,
                          subject: Text("Lunar Birthdays"),
                          message: Text("Track-Download \("https://apps.apple.com/us/app/lunar-birthdays/id6468920519")")) {
                    Text("Share-With-Others")
                }
            }
            .alert(isPresented: Binding<Bool>(
                get: {
                    showNotificationPermissionAlert || showCalendarPermissionAlert || showExportAlert || showEmptyAlert || showSignOutAlert || googleCalendar.showExportAlert
                },
                set: { newValue in
                }
            )) {
                if showNotificationPermissionAlert {
                    return Alert(
                        title: Text("Notification-Permission"),
                        message: Text("Notification-Confirm"),
                        primaryButton: .default(Text("Settings-Title"), action: {
                            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
                            UIApplication.shared.open(settingsURL)
                            showNotificationPermissionAlert = false
                        }),
                        secondaryButton: .cancel{
                            showNotificationPermissionAlert = false
                        }
                    )
                } else if showCalendarPermissionAlert {
                    return Alert(
                        title: Text("Calendar-Permission"),
                        message: Text("Calendar-Confirm"),
                        primaryButton: .default(Text("Settings-Title"), action: {
                            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
                            UIApplication.shared.open(settingsURL)
                            showCalendarPermissionAlert = false
                        }),
                        secondaryButton: .cancel{
                            showCalendarPermissionAlert = false
                        }
                    )
                } else if showExportAlert || googleCalendar.showExportAlert{
                    return Alert(
                        title: Text("Export"),
                        message: Text("Export-Confirm"),
                        primaryButton: .default(Text("Export")) {
                            showExportAlert = false
                            
                            hud.textLabel.text = "Exporting"
                            hud.detailTextLabel.text = "0%"
                            hud.indicatorView = JGProgressHUDRingIndicatorView()
                            hud.style = darkMode ? .extraLight : .dark
                            
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let window = windowScene.windows.first {
                                hud.show(in: window)
                            }
                            
                            let birthdayArray = Array(birthday)
                            if googleCalendar.showExportAlert {
                                googleCalendar.showExportAlert = false
                                googleCalendar.exportBirthdays(birthdayArray, exportValue, progress: { progressPercentage in
                                    DispatchQueue.main.async {
                                        hud.detailTextLabel.text = String(format: "%.0f%%", progressPercentage * 100)
                                    }
                                }) {
                                    DispatchQueue.main.async {
                                        hud.dismiss(afterDelay: 1.5, animated: true)
                                        hud.textLabel.text = "Success"
                                        hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                                    }
                                }
                            } else {
                                showExportAlert = false
                                exportBirthdays(birthdayArray, exportValue, progress: { progressPercentage in
                                    DispatchQueue.main.async {
                                        hud.detailTextLabel.text = String(format: "%.0f%%", progressPercentage * 100)
                                    }
                                }) {
                                    DispatchQueue.main.async {
                                        hud.dismiss(afterDelay: 1.5, animated: true)
                                        hud.textLabel.text = "Sucess"
                                        hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                                    }
                                }
                            }
                        },
                        secondaryButton: .cancel{
                            showExportAlert = false
                            googleCalendar.showExportAlert = false
                        }
                    )
                } else if showSignOutAlert {
                    return Alert(
                        title: Text("Google-Calendar"),
                        message: Text("Sign-Out-Success"),
                        dismissButton: .default(Text("Ok")) {
                            showSignOutAlert = false
                        }
                    )
                } else if showEmptyAlert {
                    return Alert(
                        title: Text("Export"),
                        message: Text("No-Birthdays"),
                        dismissButton: .default(Text("Ok")) {
                            showEmptyAlert = false
                        }
                    )
                } else {
                    return Alert(title: Text("Unknown-Alert"))
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if googleCalendar.isSignedIn {
                    Button(action: {
                        googleCalendar.signOut()
                        showSignOutAlert = true
                    }) {
                        Text("Sign-Out")
                    }
                }
            }
        }
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
            getNotificationPermission { isAuthorized in
                if isAuthorized {
                    notifications = true
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
