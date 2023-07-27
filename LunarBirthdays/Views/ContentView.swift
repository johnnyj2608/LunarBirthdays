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
    @FetchRequest(sortDescriptors: [SortDescriptor(\.date)]) var birthday: FetchedResults<Birthday>
    
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(birthday) { birthday in
                        NavigationLink(destination: ProfileView(birthday: birthday), label: {
                            BirthdayCell(birthday: birthday)
                        })
                    }
                }
                .searchable(text: $searchText)
                .onChange(of: searchText) { newValue in
                    birthday.nsPredicate = newValue.isEmpty ? nil : NSPredicate(format: "firsts CONTAINS %@ || lasts CONTAINS %@", newValue, newValue)
                }
            }
            .navigationTitle("Birthdays")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        
                    } label: {
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gear")
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {

                    } label: {
                        NavigationLink(destination: EditView()) {
                            Image(systemName: "plus.circle")
                        }
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
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
                Text("\(birthday.firsts ?? "") \(birthday.lasts ?? "")")
                    .font(.system(size: 20))
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text("Turns \(calcAge(date: birthday.date ?? Date())) on \(getMonthDay(date: birthday.date ?? Date()))")
                    .font(.system(size: 15))

            }
            Spacer()
            VStack(alignment: .center, spacing: 0) {
                Text(String(calcCountdown(date: birthday.date ?? Date())))
                    .font(.system(size: 35))
                    .foregroundColor(calcCountdown(date: birthday.date ?? Date()) < 11 ? .red : .black)
                Text("Days")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
