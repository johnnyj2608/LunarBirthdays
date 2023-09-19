//
//  WrapperView.swift
//  LunarBirthdays
//
//  Created by Johnny Jiang on 9/18/23.
//

import SwiftUI

struct WrapperView: View {
    @Binding var path: NavigationPath
    var body: some View {
        VStack {
            NavigationStack(path: $path) {
                ContentView()
            }
            Spacer()
            AdBannerView()
                .frame(height: 50)
        }
    }
}
