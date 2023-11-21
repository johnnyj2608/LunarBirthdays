//
//  GoogleCalendar.swift
//  LunarBirthdays
//
//  Created by Johnny Jiang on 10/7/23.
//

import SwiftUI
import GoogleAPIClientForREST
import GoogleSignIn
import GTMSessionFetcher

class GoogleCalendar: NSObject, ObservableObject, GIDSignInDelegate {
    @Published var isSignedIn: Bool = false
    @Published var showExportAlert: Bool = false
    private var currentUserAccessToken: String?
    
    private let scopes = ["https://www.googleapis.com/auth/calendar"]
    private let service = GTLRCalendarService()
    
    override init() {
        super.init()
        GIDSignIn.sharedInstance().clientID = "602901638701-2hd6247vgkmeoe8629pmvmk1nvudkkoc.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().scopes = scopes
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            GIDSignIn.sharedInstance().presentingViewController = rootViewController
        }
        GIDSignIn.sharedInstance().delegate = self
    }
    
    func signIn() {
        GIDSignIn.sharedInstance().signIn()
    }
    
    func signOut() {
        GIDSignIn.sharedInstance().signOut()
        isSignedIn = false
        showExportAlert = false
        currentUserAccessToken = nil
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error == nil {
            isSignedIn = true
            showExportAlert = true
            currentUserAccessToken = user.authentication.accessToken
        } else {
            isSignedIn = false
            showExportAlert = false
            currentUserAccessToken = nil
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
        }
    }
    
    func exportBirthdays(_ birthdays: [Birthday], _ repeatYears: Double, progress: @escaping (CGFloat) -> Void, completion: @escaping () -> Void) {
        guard let accessToken = currentUserAccessToken else {
            print("User not signed in.")
            return
        }
        
        let calendar = Calendar.current
        let recurrence = Int(round(repeatYears))
        let totalEvents = (birthdays.count * recurrence)+2 // +2 to account for delete/create progress
        var eventsSaved = 0
        removeCalendar { error in
            eventsSaved += 1
            progress(CGFloat(eventsSaved) / CGFloat(totalEvents))
            if let error = error {
                print("Error removing calendar: \(error.localizedDescription)")
                completion()
            } else {
                createCalendar { calendarId in
                    eventsSaved += 1
                    progress(CGFloat(eventsSaved) / CGFloat(totalEvents))
                    if let myCalendarId = calendarId {
                        for birthday in birthdays {
                            for year in 0..<recurrence {
                                let event = GTLRCalendar_Event()
                                event.summary = "\(birthday.name ?? "")'s birthday!"
                                event.descriptionProperty = birthday.note ?? ""
                                
                                var date = nextBirthday(birthday.date ?? Date())
                                if let modifiedDate = calendar.date(byAdding: .year, value: year, to: date) {
                                    date = modifiedDate
                                }
                                if birthday.lunar == true {
                                    date = lunarConverter(date)
                                }
                                
                                let startDate = GTLRDateTime(date: date)
                                let endDate = GTLRDateTime(date: date.addingTimeInterval(24 * 3600))
                                
                                event.start = GTLRCalendar_EventDateTime()
                                event.start?.dateTime = startDate
                                event.end = GTLRCalendar_EventDateTime()
                                event.end?.dateTime = endDate
                                
                                let query = GTLRCalendarQuery_EventsInsert.query(withObject: event, calendarId: myCalendarId)
                                query.additionalHTTPHeaders = ["Authorization": "Bearer \(accessToken)"]
                                
                                self.service.executeQuery(query) { (ticket, event, error) in
                                    if let error = error {
                                        print("Error creating event: \(error.localizedDescription)")
                                        completion()
                                    } else {
                                        print("Event created successfully!")
                                        eventsSaved += 1
                                        let progressPercentage = CGFloat(eventsSaved) / CGFloat(totalEvents)
                                        progress(progressPercentage)
                                        if progressPercentage >= 1.0 {
                                            DispatchQueue.main.async {
                                                completion()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        print("Failed to get the calendar ID.")
                        completion()
                    }
                }
            }
        }
        
        func createCalendar(completion: @escaping (String?) -> Void) {
            guard let accessToken = currentUserAccessToken else {
                print("User not signed in.")
                completion(nil)
                return
            }
            
            getCalendarList { (calendarList) in
                guard let calendarList = calendarList else {
                    print("Error retrieving calendar list.")
                    completion(nil)
                    return
                }
                
                if let targetCalendar = calendarList.items?.first(where: { $0.summary == "Lunar Birthdays" }),
                   let calendarId = targetCalendar.identifier {
                    print("Retrieved calendar ID for 'Lunar Birthdays': \(calendarId)")
                    completion(calendarId)
                } else {
                    print("Calendar 'Lunar Birthdays' not found. Creating a new calendar.")
                    
                    let newCalendar = GTLRCalendar_Calendar()
                    newCalendar.summary = "Lunar Birthdays"
                    
                    let calendarInsertQuery = GTLRCalendarQuery_CalendarsInsert.query(withObject: newCalendar)
                    calendarInsertQuery.additionalHTTPHeaders = ["Authorization": "Bearer \(accessToken)"]
                    
                    self.service.executeQuery(calendarInsertQuery) { (calendarTicket, calendar, calendarError) in
                        if let calendarError = calendarError {
                            print("Error creating calendar: \(calendarError.localizedDescription)")
                            completion(nil)
                        } else if let calendar = calendar as? GTLRCalendar_Calendar, let calendarId = calendar.identifier {
                            print("New calendar created successfully! Calendar ID: \(calendarId)")
                            completion(calendarId)
                        } else {
                            print("Unable to retrieve calendar ID.")
                            completion(nil)
                        }
                    }
                }
            }
        }
        
        func removeCalendar(completion: @escaping (Error?) -> Void) {
            guard let accessToken = currentUserAccessToken else {
                print("User not signed in.")
                completion(nil)
                return
            }
            
            getCalendarList { (calendarList) in
                guard let calendarList = calendarList else {
                    print("Error retrieving calendar list.")
                    completion(nil)
                    return
                }
                
                if let targetCalendar = calendarList.items?.first(where: { $0.summary == "Lunar Birthdays" }),
                   let calendarId = targetCalendar.identifier {
                    print("Deleting calendar 'Lunar Birthdays' with ID: \(calendarId)")
                    
                    let deleteQuery = GTLRCalendarQuery_CalendarsDelete.query(withCalendarId: calendarId)
                    deleteQuery.additionalHTTPHeaders = ["Authorization": "Bearer \(accessToken)"]
                    
                    self.service.executeQuery(deleteQuery) { (deleteTicket, _, deleteError) in
                        if let deleteError = deleteError {
                            print("Error deleting calendar: \(deleteError.localizedDescription)")
                            completion(deleteError)
                        } else {
                            print("Calendar 'Lunar Birthdays' deleted successfully!")
                            completion(nil)
                        }
                    }
                } else {
                    print("Calendar 'Lunar Birthdays' not found.")
                    completion(nil)
                }
            }
        }
        
        func getCalendarList(completion: @escaping (GTLRCalendar_CalendarList?) -> Void) {
            guard let accessToken = currentUserAccessToken else {
                print("User not signed in.")
                completion(nil)
                return
            }
            
            let query = GTLRCalendarQuery_CalendarListList.query()
            query.additionalHTTPHeaders = ["Authorization": "Bearer \(accessToken)"]
            
            service.executeQuery(query) { (listTicket, calendarList, listError) in
                if let listError = listError {
                    print("Error retrieving calendar list: \(listError.localizedDescription)")
                    completion(nil)
                } else if let calendarList = calendarList as? GTLRCalendar_CalendarList {
                    completion(calendarList)
                } else {
                    print("Unable to retrieve calendar list.")
                    completion(nil)
                }
            }
        }
    }
}
