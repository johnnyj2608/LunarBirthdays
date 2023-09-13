//
//  ContentView.swift
//  LunarBirthdays
//
//  Created by Johnny Jiang on 7/16/23.
//

import SwiftUI
import CoreData
import Kingfisher
import Combine

struct ContentView: View {
    @Environment(\.managedObjectContext) var managedObjContext
    @FetchRequest(sortDescriptors: []) var birthday: FetchedResults<Birthday>
    @State private var searchText = ""
    
    var groupedBirthday: [Date: [Birthday]] {
        let sortedBirthdays = birthday.sorted { calcCountdown($0.date ?? Date(), calendar: $0.cal ?? "") < calcCountdown($1.date ?? Date(), calendar: $1.cal ?? "") }
        
        return Dictionary(grouping: sortedBirthdays) { birthday in
            var nextBirthday = nextBirthday(birthday.date ?? Date())
            if birthday.cal == "Lunar" {
                nextBirthday = lunarConverter(nextBirthday)
            }
            let components = Calendar.current.dateComponents([.year, .month], from: nextBirthday)
            return Calendar.current.date(from: components)!
        }
    }
    // Categorizes birthdays by upcoming months and sorts birthdays by upcoming day
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @Binding var path: NavigationPath
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                List {
                    ForEach(groupedBirthday.keys.sorted(), id: \.self) { key in
                        Section(header: Text("\(monthString(getMonth(key))) \(yearString(getYear(key)))")) {
                            ForEach(groupedBirthday[key]!, id: \.self) { birthday in
                                NavigationLink(value: Route.profileView(birthday: birthday)) {
                                    BirthdayCell(birthday: birthday, timer: timer)
                                }
                            }
                            .listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                        }
                    }
                }
                .searchable(text: $searchText)
                .onChange(of: searchText) { newValue in
                    let trimmedValue = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                    birthday.nsPredicate = trimmedValue.isEmpty ? nil : NSPredicate(format: "name BEGINSWITH[c] %@", trimmedValue)
                }
            }
            .navigationTitle("Birthdays")
            .navigationDestination(for: Route.self) { route in
                route
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(value: Route.settingsView) {
                        Image(systemName: "gear")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(value: Route.addView) {
                        Image(systemName: "plus.circle")
                    }
                }
            }
        }
        .gesture(DragGesture().onChanged { _ in
            UIApplication.shared.dismissKeyboard()
        })
        .navigationViewStyle(.stack)
        .onDisappear {
            timer.upstream.connect().cancel()
        }
    }
}

struct BirthdayCell: View {
    @ObservedObject var birthday: Birthday
    var timer: Publishers.Autoconnect<Timer.TimerPublisher>
    
    @State private var countdown: (days: Int, hours: Int, mins: Int, secs: Int) = (0, 0, 0, 0)
    
    var body: some View {
        HStack {
            KFImage(URL(fileURLWithPath: birthday.img ?? ""))
                .resizable()
                .scaledToFit()
                .frame(width: 65, height: 65)
                .clipShape(Circle())
                .padding(.vertical, 4)
            VStack(alignment: .leading, spacing: 5) {
                Text("\(birthday.name ?? "")")
                    .font(.system(size: 20))
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text("Turns \(calcAge(birthday.date ?? Date())) on \(monthString( getMonth(birthday.date ?? Date(), calendar: birthday.cal ?? ""))) \(getDay(birthday.date ?? Date(), calendar: birthday.cal ?? ""))")
                    .font(.system(size: 15))
                    .lineLimit(1)
            }
            Spacer()
            VStack(alignment: .center, spacing: 0) {
                switch (countdown.days, countdown.hours, countdown.mins, countdown.secs) {
                case (0, 0, 0, 0):
                    Text("🎂")
                        .font(.system(size: 35))
                case (0, 0, 0, _):
                    Text("\(countdown.secs)")
                        .font(.system(size: 25))
                        .foregroundColor(countdown.days < 11 ? .red : .primary)
                    Text(countdown.secs == 1 ? "Sec" : "Secs")
                        .font(.system(size: 20))
                        .lineLimit(1)
                case (0, 0, _, _):
                    Text("\(countdown.mins)")
                        .font(.system(size: 25))
                        .foregroundColor(countdown.days < 11 ? .red : .primary)
                    Text(countdown.mins == 1 ? "Min" : "Mins")
                        .font(.system(size: 20))
                        .lineLimit(1)
                case (0, _, _, _):
                    Text("\(countdown.hours)")
                        .font(.system(size: 25))
                        .foregroundColor(countdown.days < 11 ? .red : .primary)
                    Text(countdown.hours == 1 ? "Hrs" : "Hrs")
                        .font(.system(size: 20))
                        .lineLimit(1)
                default:
                    Text("\(countdown.days)")
                        .font(.system(size: 25))
                        .foregroundColor(countdown.days < 11 ? .red : .primary)
                    Text(countdown.days == 1 ? "Day" : "Days")
                        .font(.system(size: 20))
                        .lineLimit(1)
                }
            }
            .frame(width: 50)
        }
        .onAppear {
            countdown = calcCountdown(birthday.date ?? Date(), calendar: birthday.cal!)
        }
        
        .onReceive(timer) { _ in
            countdown = calcCountdown(birthday.date ?? Date(), calendar: birthday.cal!)
        }
    }
}
