//
//  ProfileView.swift
//  Lunar Birthdays
//
//  Created by Johnny Jiang on 7/21/23.
//

import SwiftUI

struct ProfileView: View {
    var birthday: Birthday
    var body: some View {
        VStack {
            Image(birthday.picture)
                .resizable()
                .scaledToFit()
                .frame(height: 150)
                .clipShape(Circle())
            Text(birthday.name)
                .font(.system(size: 40))
                .fontWeight(.semibold)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Text(birthday.date)
                .font(.system(size: 25))
                .lineLimit(1)
                .padding(.horizontal)
                .foregroundColor(.secondary)
            // Turning X in X Days
            // Notes
            // Custom Notifications
        }
    }
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(birthday: BirthdayList.topFive.first!)
    }
}
