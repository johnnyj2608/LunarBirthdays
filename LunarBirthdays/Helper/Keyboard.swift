//
//  Keyboard.swift
//  LunarBirthdays
//
//  Created by Johnny Jiang on 7/30/23.
//

import SwiftUI

extension UIApplication {
    func dismissKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
