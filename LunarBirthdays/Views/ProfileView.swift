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
    
    @State var countdown: (days: Int, hours: Int, mins: Int, secs: Int)
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var img = ""
    
    var body: some View {
        List {
            VStack(alignment: .center) {
                KFImage(URL(fileURLWithPath: img))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .padding(.vertical, 4)
                    .cornerRadius(20)
                Text(birthday.name ?? "")
                    .font(.system(size: 40))
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                Spacer().frame(height: 10)
                Text("Full-Date \(monthString(getMonth(birthday.date ?? Date()))) \(dayString(getDay(birthday.date ?? Date()))) \(yearString(getYear(birthday.date ?? Date())))")
                    .font(.system(size: 25))
                    .lineLimit(1)
                    .padding(.bottom, 1)
                Text("Zodiac \(getZodiac(birthday.date ?? Date(), birthday.lunar))")
                    .font(.system(size: 20))
                    .lineLimit(1)
                    .foregroundColor(Color.secondary)
            }
            .frame(maxWidth: .infinity)
            Section(footer: Text(LocalizedStringKey(birthday.lunar ? "LunarTrack" : "GregorianTrack"))
                .font(.headline)) {
                VStack {
                    Text("Countdown-In \(calcAge(birthday.date ?? Date(), birthday.lunar))")
                        .font(.system(size: 25))
                        .padding(.bottom, 1)
                    HStack {
                        switch (countdown.days, countdown.hours, countdown.mins, countdown.secs) {
                        case (0, 0, 0, 0):
                            Text("Today")
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
                }
                .frame(maxWidth: .infinity)
            }
            Section {
                VStack {
                    Text("NextLunarBirthday")
                        .font(.system(size: 25))
                        .padding(.bottom, 2)
                    Text(nextLunarBirthday(birthday.date ?? Date(), birthday.lunar))
                        .font(.system(size: 25))
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity)
            Section {
                if birthday.note?.isEmpty == false {
                    Text(birthday.note ?? "")
                } else {
                    Text("Note")
                }
            }
            .onAppear {
                if let imgName = birthday.img, !imgName.isEmpty {
                    img = DataController.shared.relativePath(for: imgName).path
                } else {
                    img = ""
                }
                
                timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
                countdown = calcCountdown(birthday.date ?? Date(), birthday.lunar)
            }
            .onReceive(timer) { _ in
                countdown = calcCountdown(birthday.date ?? Date(), birthday.lunar)
            }
            .onDisappear {
                timer.upstream.connect().cancel()
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                NavigationLink("Edit-Title", value: Route.editView(birthday: birthday))
            }
        }
    }
}
