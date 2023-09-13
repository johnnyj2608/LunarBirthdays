//
//  ProfileView.swift
//  LunarBirthdays
//
//  Created by Johnny Jiang on 7/21/23.
//

import SwiftUI
import Kingfisher

struct ProfileView: View {
    
    @Environment(\.managedObjectContext) var managedObjContext
    @ObservedObject var birthday: Birthday
    
    @State private var countdown: (days: Int, hours: Int, mins: Int, secs: Int) = (0, 0, 0, 0)
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        List {
            VStack(alignment: .center) {
                KFImage(URL(fileURLWithPath: birthday.img ?? ""))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .padding(.vertical, 4)
                Text("\(birthday.name ?? "")")
                    .font(.system(size: 40))
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                Text(dateString(birthday.date ?? Date()))
                    .font(.system(size: 25))
                    .lineLimit(1)
                Text("\(birthday.cal ?? "")")
                    .font(.system(size: 20))
                    .lineLimit(1)
                    .foregroundColor(Color.secondary)
            }
            .frame(maxWidth: .infinity)
            Section {
                VStack {
                    Text("Turns \(calcAge(birthday.date ?? Date(), calendar: birthday.cal ?? "")) in")
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
                                    .foregroundColor(countdown.days == 0 ? .red : .primary)
                                Text(countdown.days == 1 ? "Day" : "Days")
                                    .font(.system(size: 25))
                            }
                            Spacer()
                            VStack {
                                Text("\(countdown.hours)")
                                    .font(.system(size: 30))
                                    .foregroundColor(countdown.days == 0 ? .red : .primary)
                                Text(countdown.hours == 1 ? "Hour" : "Hours")
                                    .font(.system(size: 25))
                            }
                            Spacer()
                            VStack {
                                Text("\(countdown.mins)")
                                    .font(.system(size: 30))
                                    .foregroundColor(countdown.days == 0 ? .red : .primary)
                                Text(countdown.mins == 1 ? "Min" : "Mins")
                                    .font(.system(size: 25))
                            }
                            Spacer()
                            VStack {
                                Text("\(countdown.secs)")
                                    .font(.system(size: 30))
                                    .foregroundColor(countdown.days == 0 ? .red : .primary)
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
                countdown = calcCountdown(birthday.date ?? Date(), calendar: birthday.cal!)
            }
            .onReceive(timer) { _ in
                countdown = calcCountdown(birthday.date ?? Date(), calendar: birthday.cal!)
            }
            .onDisappear {
                timer.upstream.connect().cancel()
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    NavigationLink("Edit", value: Route.editView(birthday: birthday))
                }
            }
        }
    }
}
