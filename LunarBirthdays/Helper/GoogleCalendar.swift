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
        isSignedIn = isUserSignedIn()
    }
    
    func signIn() {
        GIDSignIn.sharedInstance().signIn()
    }
    
    func signOut() {
        GIDSignIn.sharedInstance().signOut()
        isSignedIn = false
    }
    
    func isUserSignedIn() -> Bool {
        return GIDSignIn.sharedInstance().currentUser != nil
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error == nil {
            isSignedIn = true
            exportBirthdays()
        } else {
            isSignedIn = false
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
        }
    }
    
    func exportBirthdays() {
        guard let currentUser = GIDSignIn.sharedInstance().currentUser else {
            print("User not signed in.")
            return
        }
        guard let accessToken = currentUser.authentication.accessToken else {
            print("Access token not available.")
            return
        }
        
        deleteCalendar { deleteError in
            if let deleteError = deleteError {
                print("Error deleting calendar: \(deleteError.localizedDescription)")
                return
            }
            
            self.createCalendar { calendarId in
                if let myCalendarId = calendarId {
                    let event = GTLRCalendar_Event()
                    event.summary = "Birthday Party"
                    event.descriptionProperty = "A birthday celebration"
                    
                    let startDate = GTLRDateTime(date: Date())
                    let endDate = GTLRDateTime(date: Date(timeIntervalSinceNow: 3600))
                    event.start = GTLRCalendar_EventDateTime()
                    event.start?.dateTime = startDate
                    event.end = GTLRCalendar_EventDateTime()
                    event.end?.dateTime = endDate
                    
                    let query = GTLRCalendarQuery_EventsInsert.query(withObject: event, calendarId: myCalendarId)
                    query.additionalHTTPHeaders = ["Authorization": "Bearer \(accessToken)"]
                    
                    self.service.executeQuery(query) { (ticket, event, error) in
                        if let error = error {
                            print("Error creating event: \(error.localizedDescription)")
                        } else {
                            print("Event created successfully!")
                        }
                    }
                } else {
                    print("Failed to get the calendar ID.")
                }
            }
        }
    }
    
    
    func createCalendar(completion: @escaping (String?) -> Void) {
        guard let currentUser = GIDSignIn.sharedInstance().currentUser else {
            print("User not signed in.")
            completion(nil)
            return
        }
        guard let accessToken = currentUser.authentication.accessToken else {
            print("Access token not available.")
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
    
    func deleteCalendar(completion: @escaping (Error?) -> Void) {
        guard let currentUser = GIDSignIn.sharedInstance().currentUser else {
            print("User not signed in.")
            completion(nil)
            return
        }
        guard let accessToken = currentUser.authentication.accessToken else {
            print("Access token not available.")
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
        guard let currentUser = GIDSignIn.sharedInstance().currentUser else {
            print("User not signed in.")
            completion(nil)
            return
        }
        guard let accessToken = currentUser.authentication.accessToken else {
            print("Access token not available.")
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
