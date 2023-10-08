//
//  WheelPicker.swift
//  LunarBirthdays
//
//  Created by Johnny Jiang on 7/27/23.
//

import SwiftUI

struct WheelDatePicker: View {
    @Binding var selectedDate: Date
    @State private var isPickerVisible = false
    
    private let start: Date = {
            var components = DateComponents()
            components.year = 1900
            return Calendar.current.date(from: components)!
        }()
    
    var body: some View {
        HStack {
            Text("Date")
            Spacer()
            HStack(spacing: 1) {
                if let selectedDate = selectedDate {
                    Text(selectedDate, style: .date)
                        .foregroundColor(.gray)
                } else {
                    Text("Select Date")
                        .foregroundColor(.gray)
                }
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }

        }
        .onTapGesture {
            withAnimation {
                isPickerVisible.toggle()
            }
        }
        
        if isPickerVisible {
            VStack(spacing: 0) {
                HStack(alignment: .center) {
                    Button("Done") {
                        withAnimation {
                            isPickerVisible.toggle()
                        }
                    }
                }
                .padding(.top, 3)
                .frame(maxWidth: .infinity)
                .foregroundColor(.blue)
                DatePicker("", selection: $selectedDate, in: start...Date(), displayedComponents: .date)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .frame(maxHeight: 300)
            }
        }
    }
}
