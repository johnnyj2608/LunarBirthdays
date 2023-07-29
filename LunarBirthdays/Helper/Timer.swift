//
//  TimerManager.swift
//  LunarBirthdays
//
//  Created by Johnny Jiang on 7/28/23.
//

import Foundation

class TimerManager: ObservableObject {
    private var timer: Timer?

    func startTimer(withInterval interval: TimeInterval = 1.0, handler: @escaping () -> Void) {
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            handler()
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

