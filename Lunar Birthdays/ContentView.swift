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
            List(birthdays, id: \.id) { birthday in
                NavigationLink(destination: ProfileView(birthday: birthday), label: {
                    BirthdayCell(birthday: birthday)
                })
            }
            //.listStyle(PlainListStyle())
            .navigationTitle("Birthdays")
            .navigationBarTitleDisplayMode(.inline)
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
                        // TODO
                    } label: {
                        NavigationLink(destination: EditView()) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
        }
    }
}

struct BirthdayCell: View {
    var birthday: Birthday
    var body: some View {
        HStack{
            Image(birthday.picture)
                .resizable()
                .scaledToFill()
                .frame(width: 70, height: 70)
                .clipShape(Circle())
                .padding(.vertical, 4)
            VStack(alignment: .leading, spacing: 5) {
                Text(birthday.name)
                    .font(.system(size: 20))
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text(birthday.date)
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
            }
            Spacer()
            VStack(alignment: .center, spacing: 0) {
                Text(String(birthday.countdown))
                    .font(.system(size: 35))
                    .foregroundColor(birthday.countdown < 11 ? .red : .black)
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
