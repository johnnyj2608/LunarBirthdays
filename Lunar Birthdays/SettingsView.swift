//
//  Settings.swift
//  Lunar Birthdays
//
//  Created by Johnny Jiang on 7/21/23.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            /*
            Form {
                Section(header: Text("Display"), footer: Text("System Override")) {
                    Toggle(isOn: .constant(true), label: {
                        Text("Dark Mode")
                    })
                    Toggle(isOn: .constant(true), label: {
                        Text("Dark Mode")
                    })
                }
            }
             */
            Form {
                Section(header: Text("Upgrade")) {
                    Text("Birthday Reminder Pro")
                }
                Section(header: Text("Notificaitons")) {
                    Text("When Bro")
                }
                Section(header: Text("Leap Year")) {
                    Text("February 29")
                }
                Section(header: Text("Visual")) {
                    Text("Dark Mode")
                }
                Section(header: Text("Feedback")) {
                    Text("Rate this app")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
