// 
//  ContentView.swift
//  Lunar Birthdays
//
//  Created by Johnny Jiang on 7/16/23.
//

import SwiftUI

struct ContentView: View {
    var birthdays: [Birthday] = BirthdayList.topFive
    var body: some View {
        NavigationView {
            List(birthdays, id: \.id) { bday in
                HStack{
                    Image(bday.picture)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 70, height: 70)
                        .clipShape(Circle())
                        .padding(.vertical, 4)
                    VStack(alignment: .leading, spacing: 5) {
                        Text(bday.name)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        Text(bday.date)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text(String(bday.countdown))
                        .font(.system(size: 40))
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Birthdays")
            .navigationBarTitleDisplayMode(.inline)
            
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        // TODO
                    } label: {
                        NavigationLink(destination: settingsView()) {
                            Image(systemName: "gear")
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // TODO
                    } label: {
                        NavigationLink(destination: addView()) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
        }
    }
}

struct addView: View {
    var body: some View {
        NavigationView {
            CircleNumberView(color: .red, number: 1)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // TODO
                    } label: {
                        NavigationLink(destination: settingsView()) {
                            Image(systemName: "save")
                        }
                    }
                }
            }
        }
    }
}

struct settingsView: View {
    var body: some View {
        Text("Settings")
    }
}

struct CircleNumberView: View {
    var color: Color
    var number: Int
    
    var body: some View {
        ZStack {
            Circle()
                .frame(width: 200, height: 200)
                .foregroundColor(color)
            Text("\(number)")
                .foregroundColor(.white)
                .font(.system(size: 70, weight: .bold))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
