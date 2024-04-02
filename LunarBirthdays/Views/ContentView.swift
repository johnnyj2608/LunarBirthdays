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
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var searchText = ""
    
    @State private var groupedBirthday: [Date: [Birthday]] = [:]
    @State private var pinnedBirthdays: [Birthday] = []
    
    @State private var isPresentingConfirm: Bool = false
    @State private var selectedBirthday: Birthday?
    
    var body: some View {
        VStack {
            List {
                if !pinnedBirthdays.isEmpty {
                    Section(header: Text("Pinned")) {
                        ForEach(pinnedBirthdays, id: \.self) { birthday in
                            NavigationLink(value: Route.profileView(birthday: birthday)) {
                                BirthdayCell(birthday: birthday, timer: $timer)
                            }
                            .padding([.leading, .trailing], 10)
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
                ForEach(groupedBirthday.keys.sorted(), id: \.self) { key in
                    Section(header: Text("Month-Year \(monthString(getMonth(key))) \(yearString(getYear(key)))")) {
                        ForEach(groupedBirthday[key]!, id: \.self) { birthday in
                            NavigationLink(value: Route.profileView(birthday: birthday)) {
                                BirthdayCell(birthday: birthday, timer: $timer)
                            }
                            .padding([.leading, .trailing], 10)
                            //.border(nextBirthday(birthday.date ?? Date(), birthday.lunar) == Calendar.current.startOfDay(for: Date()) ? Color.red : Color.clear, width: 2)
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
            }
            .refreshable {
                updateGroupedBirthdays()
            }
            .onChange(of: searchText) { newValue in
                let trimmedValue = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                birthday.nsPredicate = trimmedValue.isEmpty ? nil : NSPredicate(format: "name BEGINSWITH[c] %@", trimmedValue)
            }
        }
        .searchable(text: $searchText)
        .navigationTitle("Birthday-Title")
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
        .gesture(DragGesture().onChanged { _ in
            UIApplication.shared.dismissKeyboard()
        })
        .navigationViewStyle(.stack)
        
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            updateGroupedBirthdays()
        }
        .onAppear {
            updateGroupedBirthdays()
        }
        .onDisappear {
            timer.upstream.connect().cancel()
        }
        .confirmationDialog("Delete", isPresented: $isPresentingConfirm) {
            Button("Are-You-Sure", role: .destructive) {
                DataController.shared.deleteBirthday(birthday: selectedBirthday!, context: managedObjContext)
                updateGroupedBirthdays()
            }
        }
    }
    private func updateGroupedBirthdays() {
        let sortedBirthdays = birthday.sorted { calcCountdown($0.date ?? Date(), $0.lunar) < calcCountdown($1.date ?? Date(), $1.lunar) }
        
        let regularBirthdays = sortedBirthdays.filter { !$0.pin }
        groupedBirthday = Dictionary(grouping: regularBirthdays) { birthday in
            let nextBirthday = nextBirthday(birthday.date ?? Date(), birthday.lunar)
            let components = Calendar.current.dateComponents([.year, .month], from: nextBirthday)
            return Calendar.current.date(from: components)!
        }
        
        pinnedBirthdays = sortedBirthdays.filter { $0.pin }
    }
}

struct BirthdayCell: View {
    
    @ObservedObject var birthday: Birthday
    @Binding var timer: Publishers.Autoconnect<Timer.TimerPublisher>
    @State private var countdown: (days: Int, hours: Int, mins: Int, secs: Int) = (0, 0, 0, 0)
    
    @State private var img = ""
    
    var body: some View {
        HStack {
            KFImage(URL(fileURLWithPath: img))
                .resizable()
                .scaledToFill()
                .frame(width: 55, height: 55)
                .padding(.vertical, 4)
                .cornerRadius(10)
            VStack(alignment: .leading, spacing: 5) {
                Text("\(birthday.name ?? "")")
                    .font(.system(size: 20))
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text("Countdown-On \(calcAge(birthday.date ?? Date(), birthday.lunar)) \(monthString(getMonth(birthday.date ?? Date(), birthday.lunar))) \(getDay(birthday.date ?? Date(), birthday.lunar))")
                    .font(.system(size: 15))
                    .lineLimit(2)
            }
            Spacer()
            VStack(alignment: .center, spacing: 0) {
                switch (countdown.days, countdown.hours, countdown.mins, countdown.secs) {
                case (0, 0, 0, 0):
                    Text("🎂")
                        .font(.system(size: 30))
                        .rainbowStyle(retainColor: true)
                case (0, 0, 0, _):
                    Text("\(countdown.secs)")
                        .font(.system(size: 20))
                        .foregroundColor(countdown.days < 11 ? .red : .primary)
                    Text(countdown.secs == 1 ? "Sec" : "Secs")
                        .font(.system(size: 15))
                        .lineLimit(1)
                case (0, 0, _, _):
                    Text("\(countdown.mins)")
                        .font(.system(size: 20))
                        .foregroundColor(countdown.days < 11 ? .red : .primary)
                    Text(countdown.mins == 1 ? "Min" : "Mins")
                        .font(.system(size: 15))
                        .lineLimit(1)
                case (0, _, _, _):
                    Text("\(countdown.hours)")
                        .font(.system(size: 20))
                        .foregroundColor(countdown.days < 11 ? .red : .primary)
                    Text(countdown.hours == 1 ? "Hrs" : "Hrs")
                        .font(.system(size: 15))
                        .lineLimit(1)
                default:
                    Text("\(countdown.days)")
                        .font(.system(size: 20))
                        .foregroundColor(countdown.days < 11 ? .red : .primary)
                    Text(countdown.days == 1 ? "Day" : "Days")
                        .font(.system(size: 15))
                        .lineLimit(1)
                }
            }
            .frame(width: 50)
        }
        .onAppear {
            if let imgName = birthday.img, !imgName.isEmpty {
                img = DataController.shared.relativePath(for: imgName).path
            } else {
                img = ""
            }
            
            countdown = calcCountdown(birthday.date ?? Date(), birthday.lunar)
        }
        
        .onReceive(timer) { _ in
            countdown = calcCountdown(birthday.date ?? Date(), birthday.lunar)
        }
    }
}
