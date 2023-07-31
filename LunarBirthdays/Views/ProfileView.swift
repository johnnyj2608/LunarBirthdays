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
    
    @State private var countdown: (days: Int, hours: Int, mins: Int, secs: Int) = (0, 0, 0, 0)
    @StateObject private var timerManager = TimerManager()
    
    var body: some View {
        List {
            VStack(alignment: .center) {
                //Image(uiImage: UIImage(data: birthday.img ?? Data()) ?? UIImage())
                Image("andrewYang")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                Text("\(birthday.name ?? "")")
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
                        .padding(.bottom, 1)
                    HStack {
                        switch (countdown.days, countdown.hours, countdown.mins, countdown.secs) {
                        case (0, 0, 0, 0):
                            Text("Today!")
                                .font(.system(size: 50))
                                .rainbowStyle()
                        default:
                            VStack {
                                Text("\(countdown.days)")
                                    .font(.system(size: 30))
                                    .foregroundColor(countdown.days == 0 ? .red : .black)
                                Text(countdown.days == 1 ? "Day" : "Days")
                                    .font(.system(size: 25))
                            }
                            Spacer()
                            VStack {
                                Text("\(countdown.hours)")
                                    .font(.system(size: 30))
                                    .foregroundColor(countdown.days == 0 ? .red : .black)
                                Text(countdown.hours == 1 ? "Hour" : "Hours")
                                    .font(.system(size: 25))
                            }
                            Spacer()
                            VStack {
                                Text("\(countdown.mins)")
                                    .font(.system(size: 30))
                                    .foregroundColor(countdown.days == 0 ? .red : .black)
                                Text(countdown.mins == 1 ? "Min" : "Mins")
                                    .font(.system(size: 25))
                            }
                            Spacer()
                            VStack {
                                Text("\(countdown.secs)")
                                    .font(.system(size: 30))
                                    .foregroundColor(countdown.days == 0 ? .red : .black)
                                Text(countdown.secs == 1 ? "Sec" : "Secs")
                                    .font(.system(size: 25))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            Section {
                Text(birthday.note?.isEmpty == true ? "Note" : birthday.note ?? "")
            }
            .onAppear {
                countdown = calcCountdown(date: birthday.date ?? Date())
                timerManager.startTimer {
                    countdown = calcCountdown(date: birthday.date ?? Date())
                }
            }
            .onDisappear {
                timerManager.stopTimer()
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
}


struct ProfileView_Previews: PreviewProvider {
    static let context = PersistenceController.preview.container.viewContext
    
    static var previews: some View {
        let birthday = Birthday(context: context)
        birthday.name = "Andrew Yang"
        birthday.date = Date()
        birthday.note = "Testing note"
        
        return ProfileView(birthday: birthday)
    }
}
