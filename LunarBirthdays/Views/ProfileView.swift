//
//  ProfileView.swift
//  LunarBirthdays
//
//  Created by Johnny Jiang on 7/21/23.
//

import SwiftUI
import CoreData

struct ProfileView: View {
    
    @Environment(\.managedObjectContext) var managedObjContext
    @ObservedObject var birthday: Birthday
    @State private var isPresentingConfirm: Bool = false
    
    var body: some View {
        VStack {
            Image("andrewYang")
                .resizable()
                .scaledToFit()
                .frame(height: 150)
                .clipShape(Circle())
                .padding(15)
            Text("\(birthday.first ?? "") \(birthday.last ?? "")")
                .font(.system(size: 40))
                .fontWeight(.semibold)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Text(dateString(date: birthday.date ?? Date()))
                .font(.system(size: 25))
                .lineLimit(1)
                .padding(.horizontal)
                .foregroundColor(.secondary)
            Text("Turns \(calcAge(date: birthday.date ?? Date())) on \(calcCountdown(date: birthday.date ?? Date())) Days")
                .padding(40)
            Text(birthday.note ?? "")
                .padding()
                .background(.secondary)
            Spacer()
            Button ("Delete", role: .destructive){
                isPresentingConfirm = true
            }
            .confirmationDialog("Are you sure?",
                                isPresented: $isPresentingConfirm) {
                Button("Are you sure?", role: .destructive) {
                    DataController().deleteBirthday(birthday: birthday, context: managedObjContext)
                }
            }
        }
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    // TODO
                } label: {
                    NavigationLink(destination: EditView(birthday: birthday)) {
                        Text("Edit")
                    }
                }
            }
            
        }
    }
}


struct ProfileView_Previews: PreviewProvider {
    static let context = PersistenceController.preview.container.viewContext
    
    static var previews: some View {
        let birthday = Birthday(context: context)
        birthday.first = "Yang"
        birthday.last = "Yang"
        birthday.date = Date()
        birthday.note = "Testing note"
        
        return ProfileView(birthday: birthday)
    }
}
