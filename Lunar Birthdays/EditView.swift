//
//  EditView.swift
//  Lunar Birthdays
//
//  Created by Johnny Jiang on 7/21/23.
//

import SwiftUI

struct EditView: View {
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var birthday = Date()
    @State private var news = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                    DatePicker("Birth Date", selection: $birthday, displayedComponents: .date)
                }
                Section(header: Text("Action")) {
                    Toggle("Send News", isOn: $news)
                        .toggleStyle(SwitchToggleStyle(tint:.red))
                }
            }
            
            .navigationTitle("Account")
            //.onTapGesture {
            //   hideKeyboard()
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Save", action: saveUser)
                    }
                }
            }
        .accentColor(.red)
        }
    func saveUser() {
        print("User saved")
    }
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView()
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
