//
//  ProfileView.swift
//  LunarBirthdays
//
//  Created by Johnny Jiang on 7/21/23.
//

import SwiftUI

struct ProfileView: View {
    
    @Environment(\.managedObjectContext) var managedObjContext
    var birthday: Birthday
    
    var body: some View {
        VStack {
            Image("andrewYang")
                .resizable()
                .scaledToFit()
                .frame(height: 150)
                .clipShape(Circle())
            Text(birthday.name!)
                .font(.system(size: 40))
                .fontWeight(.semibold)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Text(dateString(date: birthday.date!))
                .font(.system(size: 25))
                .lineLimit(1)
                .padding(.horizontal)
                .foregroundColor(.secondary)
            // Turning X in X Days
            // Notes
            // Custom Notifications */
            Button ("Delete" ){
                // Need confirmations
                DataController().deleteBirthday(birthday: birthday, context: managedObjContext)
            }
        }
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    // TODO
                } label: {
                    NavigationLink(destination: EditView()) {
                        Text("Edit")
                    }
                }
            }
            
        }
    }
}

/*
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
*/
