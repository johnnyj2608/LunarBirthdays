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
    
    private let scopes = [kGTLRAuthScopeCalendar]
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
        print("hey")
    }
}
