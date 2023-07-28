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
    
    var body: some View {
        Form {
            VStack(alignment: .center) {
                Image("andrewYang")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .clipShape(Circle())
                Text("\(birthday.firsts ?? "") \(birthday.lasts ?? "")")
                    .font(.system(size: 40))
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                Text(dateString(date: birthday.date ?? Date()))
                    .font(.system(size: 25))
                    .lineLimit(1)
            }
            
            .frame(maxWidth: .infinity)
            Section {
                VStack {
                    Text("Turns \(calcAge(date: birthday.date ?? Date())) in")
                        .font(.system(size: 25))
                    let countdown = calcCountdown(date: birthday.date ?? Date())
                    switch countdown {
                    case 0:
                        Text("Today")
                            .font(.system(size: 40))
                    default:
                        Text("\(countdown) \(countdown == 1 ? "Day" : "Days")")
                            .font(.system(size: 40))
                    }
                }
                .frame(maxWidth: .infinity)
            }
            Section(header: Text("Note")) {
                Text(birthday.note ?? "")
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
        birthday.firsts = "Yang"
        birthday.lasts = "Yang"
        birthday.date = Date()
        birthday.note = "Testing note"
        
        return ProfileView(birthday: birthday)
    }
}
