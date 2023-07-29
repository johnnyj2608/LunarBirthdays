//
//  Rainbow.swift
//  LunarBirthdays
//
//  Created by Johnny Jiang on 7/29/23.
//

import SwiftUI

struct RainbowText: ViewModifier {
    @State private var isScaled: Bool = false

    func body(content: Content) -> some View {
        content
            .foregroundColor(.clear)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.red, .orange, .yellow, .green, .blue, .purple, .pink, .red]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .mask(content)
            )
            .font(.system(size: isScaled ? 40 * 1.2 : 40))
            .scaleEffect(isScaled ? 1.2 : 1.0)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 1).repeatForever()) {
                    isScaled.toggle()
                }
            }
    }
}

extension View {
    func rainbowStyle() -> some View {
        self.modifier(RainbowText())
    }
}

