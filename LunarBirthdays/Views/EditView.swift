//
//  EditView.swift
//  LunarBirthdays
//
//  Created by Johnny Jiang on 7/21/23.
//

import SwiftUI
import PhotosUI

struct EditView: View {
    
    @Environment(\.managedObjectContext) var managedObjContext
    @Environment(\.dismiss) var dismiss
    
    @State private var avatarItem: PhotosPickerItem?
    @State private var avatarImage = Image("andrewYang")
    
    @State private var first = ""
    @State private var last = ""
    @State private var date = Date()
    @State private var note = ""
    
    @State private var selectedCalendar = "Lunar"
    let calendars = ["Lunar", "Gregorian"]
    
    var body: some View {
        VStack {
            avatarImage
                .resizable()
                .scaledToFill()
                .frame(height: 250)
                .clipShape(Circle())
            PhotosPicker("Select Avatar", selection: $avatarItem, matching: .images)
            Form {
                Section(header: Text("Bio")) {
                    TextField("First Name", text: $first)
                    TextField("Last Name", text: $last)
                }
                Section(header: Text("Birthday")) {
                    Picker("Calendar", selection: $selectedCalendar) {
                        ForEach(calendars, id: \.self) {
                            Text($0)
                        }
                    }
                    DatePicker("Date", selection: $date, in: ...Date(), displayedComponents: .date)
                }
                Section(header: Text("Notes")) {
                    TextField("Notes", text: $note)
                }
            }
        }
        .onChange(of: avatarItem) { _ in
            Task {
                if let data = try? await avatarItem?.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data) {
                        avatarImage = Image(uiImage: uiImage)
                        return
                    }
                }
                print("Failed")
            }
        }
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button("Save") {
                    let name = first.trimmingCharacters(in: .whitespaces)+" "+last.trimmingCharacters(in: .whitespaces)
                    DataController().addBirthday(name: name, date: date, note: note, context: managedObjContext)
                    dismiss()
                }
                .disabled((first+last).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                //.disabled(last.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView()
    }
}
