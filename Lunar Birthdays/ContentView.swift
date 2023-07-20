// 
//  ContentView.swift
//  Lunar Birthdays
//
//  Created by Johnny Jiang on 7/16/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                CircleNumberView(color: .red, number: 5)
                    //.navigationTitle("Red One")
                    .offset(y: -60)
                
            }
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
        Text("Add")
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
