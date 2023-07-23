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
    @FetchRequest(sortDescriptors: [SortDescriptor(\.date, order: .reverse)]) var birthday: FetchedResults<Birthday>
    
    @State private var showingEditView = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                List {
                    ForEach(birthday) { birthday in
                        NavigationLink(destination: ProfileView(birthday: birthday), label: {
                            BirthdayCell(birthday: birthday)
                        })
                    }
                }
            }
            .navigationTitle("Birthdays")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        // TODO
                        
                    } label: {
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gear")
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingEditView.toggle()
                    } label: {
                        NavigationLink(destination: EditView()) {
                            Image(systemName: "plus.circle")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingEditView) {
                EditView()
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct BirthdayCell: View {
    var birthday: Birthday
    var body: some View {
        HStack {
            Image("andrewYang")
                .resizable()
                .scaledToFill()
                .frame(height: 70)
                .clipShape(Circle())
                .padding(.vertical, 4)
            VStack(alignment: .leading, spacing: 5) {
                Text(birthday.name!)
                    .font(.system(size: 20))
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text(nextBirthday(date: birthday.date!))
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
            }
            Spacer()
            VStack(alignment: .center, spacing: 0) {
                Text(String(calcCountdown(date: birthday.date!)))
                    .font(.system(size: 35))
                    .foregroundColor(calcCountdown(date: birthday.date!) < 11 ? .red : .black)
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
