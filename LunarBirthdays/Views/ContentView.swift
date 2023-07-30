//
//  ContentView.swift
//  LunarBirthdays
//
//  Created by Johnny Jiang on 7/16/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) var managedObjContext
    @FetchRequest(sortDescriptors: []) var birthday: FetchedResults<Birthday>
    @State private var searchText = ""
    
    var groupedBirthday: [Date: [Birthday]] {
        let sortedBirthdays = birthday.sorted { calcCountdown(date: $0.date ?? Date()) < calcCountdown(date: $1.date ?? Date()) }
        
        return Dictionary(grouping: sortedBirthdays) { birthday in
            let nextBirthday = nextBirthday(date: birthday.date ?? Date())
            let components = Calendar.current.dateComponents([.year, .month], from: nextBirthday)
            return Calendar.current.date(from: components)!
        }
    }
    
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(groupedBirthday.keys.sorted(), id: \.self) { key in
                        Section(header: Text("\(monthString(month: getMonth(date: key))) \(yearString(year: getYear(date: key)))")) {
                            ForEach(groupedBirthday[key]!, id: \.self) { birthday in
                                NavigationLink(destination: ProfileView(birthday: birthday)) {
                                    BirthdayCell(birthday: birthday)
                                }
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .searchable(text: $searchText)
                .onChange(of: searchText) { newValue in
                    let trimmedValue = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                    birthday.nsPredicate = trimmedValue.isEmpty ? nil : NSPredicate(format: "name BEGINSWITH[c] %@", trimmedValue)
                }
            }
            .navigationTitle("Birthdays")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: EditView()) {
                        Image(systemName: "plus.circle")
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct BirthdayCell: View {
    @ObservedObject var birthday: Birthday
    
    @StateObject private var timerManager = TimerManager()
    @State private var countdown: (days: Int, hours: Int, mins: Int, secs: Int) = (0, 0, 0, 0)
    
    var body: some View {
        HStack {
            Image("andrewYang")
                .resizable()
                .scaledToFit()
                .frame(height: 70)
                .clipShape(Circle())
                .padding(.vertical, 4)
            VStack(alignment: .leading, spacing: 5) {
                Text("\(birthday.name ?? "")")
                    .font(.system(size: 20))
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text("Turns \(calcAge(date: birthday.date ?? Date())) on \(monthString(month: getMonth(date: birthday.date ?? Date()))) \(getDay(date: birthday.date ?? Date()))")
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
                        .foregroundColor(countdown.days < 11 ? .red : .black)
                    Text(countdown.secs == 1 ? "Sec" : "Secs")
                        .font(.system(size: 20))
                        .lineLimit(1)
                case (0, 0, _, _):
                    Text("\(countdown.mins)")
                        .font(.system(size: 25))
                        .foregroundColor(countdown.days < 11 ? .red : .black)
                    Text(countdown.mins == 1 ? "Min" : "Mins")
                        .font(.system(size: 20))
                        .lineLimit(1)
                case (0, _, _, _):
                    Text("\(countdown.hours)")
                        .font(.system(size: 25))
                        .foregroundColor(countdown.days < 11 ? .red : .black)
                    Text(countdown.hours == 1 ? "Hrs" : "Hrs")
                        .font(.system(size: 20))
                        .lineLimit(1)
                default:
                    Text("\(countdown.days)")
                        .font(.system(size: 25))
                        .foregroundColor(countdown.days < 11 ? .red : .black)
                    Text(countdown.days == 1 ? "Day" : "Days")
                        .font(.system(size: 20))
                        .lineLimit(1)
                }
            }
            .frame(width: 50)
            .onAppear {
                countdown = calcCountdown(date: birthday.date ?? Date())
                timerManager.startTimer {
                    countdown = calcCountdown(date: birthday.date ?? Date())
                }
            }
            .onDisappear {
                timerManager.stopTimer()
            }
        }
    }
}
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
