//
//  Rainbow.swift
//  LunarBirthdays
//
//  Created by Johnny Jiang on 7/29/23.
//

import SwiftUI

struct RainbowText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [.red, .orange, .yellow, .green, .blue, .purple, .pink, .red]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .mask(content)
            )
    }
}

extension View {
    func rainbowStyle() -> some View {
        self.modifier(RainbowText())
    }
}
