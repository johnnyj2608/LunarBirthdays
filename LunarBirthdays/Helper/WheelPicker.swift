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
    
    let calendar = Calendar.current
    
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
                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .frame(maxHeight: 300)
                    .onChange(of: selectedDate) { newValue in
                        let today = calendar.startOfDay(for: Date())
                        let selectedMonth = calendar.component(.month, from: selectedDate)
                        let selectedDay = calendar.component(.day, from: selectedDate)
                        
                        if selectedDate > today {
                            let newYear = calendar.component(.year, from: Date())
                            var adjustedDate = calendar.date(from: DateComponents(year: newYear, month: selectedMonth, day: selectedDay))!
                            
                            if adjustedDate > today {
                                adjustedDate = calendar.date(from: DateComponents(year: newYear - 1, month: selectedMonth, day: selectedDay))!
                            }

                            selectedDate = adjustedDate
                        } else if selectedDate < calendar.date(from: DateComponents(year: 1900, month: 1, day: 1))! {
                            let newYear = 1900
                            
                            selectedDate = calendar.date(from: DateComponents(year: newYear, month: selectedMonth, day: selectedDay))!
                        }
                    }
                
            }
        }
    }
}
