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

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(getSortedMonths(birthdayMonths: birthdayMonths), id: \.self) { month in
                        Section(header: Text(monthString(month: month))) {
                            ForEach(birthdayMonths[month]!, id: \.self) { birthday in
                                NavigationLink(destination: ProfileView(birthday: birthday), label: {
                                    BirthdayCell(birthday: birthday)
                                })
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
    
    var birthdayMonths: [Int: [Birthday]] {
        let groupedBirthdays = Dictionary(grouping: birthday, by: { getMonth(date: $0.date ?? Date()) })
        let sortedMonths = getSortedMonths(birthdayMonths: groupedBirthdays)
        var result: [Int: [Birthday]] = [:]
            for month in sortedMonths {
                result[month] = groupedBirthdays[month]?.sorted { (birthday1, birthday2) -> Bool in
                    let day1 = getDay(date: birthday1.date ?? Date())
                    let day2 = getDay(date: birthday2.date ?? Date())
                    return day1 < day2
                }
            }
        return result
    }
}

struct BirthdayCell: View {
    @ObservedObject var birthday: Birthday
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
            let countdown = calcCountdown(date: birthday.date ?? Date())
            switch countdown {
            case 0:
                Text("🎂")
                    .font(.system(size: 35))
            default:
                VStack(alignment: .center, spacing: 0) {
                    Text("\(countdown)")
                        .font(.system(size: 25))
                        .foregroundColor(countdown < 11 ? .red : .black)
                    Text(countdown == 1 ? "Day" : "Days")
                        .font(.system(size: 20))
                        .lineLimit(1)
                }
                .frame(width: 50)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
