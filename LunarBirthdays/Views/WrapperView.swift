//
//  WrapperView.swift
//  LunarBirthdays
//
//  Created by Johnny Jiang on 9/18/23.
//

import SwiftUI
import CoreData

struct WrapperView: View {
    @Environment(\.managedObjectContext) var managedObjContext
    @Binding var path: NavigationPath

    var body: some View {
        VStack {
            NavigationStack(path: $path) {
                ContentView()
            }
            Spacer()
            AdBannerView().frame(height: 50)
        }
        //.onAppear {populateCoreData(managedObjContext: managedObjContext)}
    }
}
