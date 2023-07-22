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
        Text(birthday.name)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(birthday: BirthdayList.topFive.first!)
    }
}
