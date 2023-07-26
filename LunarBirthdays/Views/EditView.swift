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
    
    var birthday: Birthday?
    
    @State var first = ""
    @State var last = ""
    @State var date = Date()
    @State var note = ""
    
    @State private var avatarItem: PhotosPickerItem?
    @State private var avatarImage = Image("andrewYang")
    
    @State private var selectedCalendar = "Lunar"
    let calendars = ["Lunar", "Gregorian"]
    
    var body: some View {
        VStack {
            avatarImage
                .resizable()
                .scaledToFit()
                .frame(height: 250)
                .clipShape(Circle())
            PhotosPicker("Select Avatar", selection: $avatarItem, matching: .images)
            Form {
                Section(header: Text("Name")) {
                    TextField("First Name", text: $first)
                        .modifier(TextFieldClearButton(text: $first))
                        .onReceive(first.publisher.collect()) {
                                first = String($0.prefix(35))
                        }
                        .onAppear {
                            first = birthday?.first ?? ""
                            last = birthday?.last ?? ""
                            date = birthday?.date ?? Date()
                            note = birthday?.note ?? ""
                        }
                    TextField("Last Name", text: $last)
                        .modifier(TextFieldClearButton(text: $last))
                        .onReceive(last.publisher.collect()) {
                                last = String($0.prefix(35))
                        }
                }
                Section(header: Text("Birthday")) {
                    Picker("Calendar", selection: $selectedCalendar) {
                        ForEach(calendars, id: \.self) {
                            Text($0)
                        }
                    }
                    DatePicker("Date", selection: $date, in: ...Date(), displayedComponents: .date)
                }
                Section(header: Text("Note")) {
                    TextEditor(text: $note)
                        .onReceive(note.publisher.collect()) {
                                note = String($0.prefix(255))
                        }
                    
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
                    if birthday != nil {
                        DataController().editBirthday(birthday: birthday!, first: first, last: last, date: date, note: note, context: managedObjContext)
                    } else {
                        DataController().addBirthday(first: first, last: last, date: date, note: note, context: managedObjContext)
                    }
                    dismiss()
                }
                .disabled((first+last).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView()
    }
}
