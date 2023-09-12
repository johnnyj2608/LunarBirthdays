//
//  Navigation.swift
//  LunarBirthdays
//
//  Created by Johnny Jiang on 9/11/23.
//

import SwiftUI

enum Route: Hashable, View {
    case profileView(birthday: Birthday)
    case editView(birthday: Birthday)
    case addView
    case settingsView
    
    var body: some View {
        switch self {
        case let .profileView(birthday):
            ProfileView(birthday: birthday)
        case let .editView(birthday):
            EditView(birthday: birthday)
        case .addView:
            EditView(navTitle: "Add")
        case .settingsView:
            SettingsView()
        }
    }
}
