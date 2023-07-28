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
    
    @State var name = ""
    @State var date = Date()
    @State var note = ""
    
    @State private var avatarItem: PhotosPickerItem?
    @State private var avatarImage = Image("andrewYang")
    
    @State private var cal = "Lunar"
    let calendars = ["Lunar", "Gregorian"]
    
    @State private var title = ""
    @State private var pickerReset = UUID()
    
    @State private var isPresentingConfirm: Bool = false
    
    var body: some View {
        Form {
            VStack {
                avatarImage
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .clipShape(Circle())
                PhotosPicker("Select Avatar", selection: $avatarItem, matching: .images)
            }
            .frame(maxWidth: .infinity)
            Section(header: Text("Name")) {
                TextField("Name", text: $name)
                    .modifier(TextFieldClearButton(text: $name))
                    .onReceive(name.publisher.collect()) {
                        name = String($0.prefix(70))
                    }
                    .onAppear {
                        name = birthday?.name ?? ""
                        date = birthday?.date ?? Date()
                        note = birthday?.note ?? ""
                        cal = birthday?.cal ?? "Lunar"
                    }
            }
            Section(header: Text("Birthday")) {
                Picker("Calendar", selection: $cal) {
                    ForEach(calendars, id: \.self) {
                        Text($0)
                    }
                }
                DatePicker("Date", selection: $date, in: ...Date(), displayedComponents: .date)
                    .datePickerStyle(.wheel)
                
            }
            Section(header: Text("Note")) {
                TextField("Note", text: $note)
                    .onReceive(note.publisher.collect()) {
                        note = String($0.prefix(255))
                    }
                
            }
            Section {
                if birthday != nil {
                    Button ("Delete", role: .destructive){
                        isPresentingConfirm = true
                    }
                    .confirmationDialog("Are you sure?",
                                        isPresented: $isPresentingConfirm) {
                        Button("Are you sure?", role: .destructive) {
                            DataController().deleteBirthday(birthday: birthday!, context: managedObjContext)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
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
                        DataController().editBirthday(birthday: birthday!, name: name, date: date, note: note, cal: cal, context: managedObjContext)
                    } else {
                        DataController().addBirthday(name: name, date: date, note: note, cal: cal, context: managedObjContext)
                    }
                    dismiss()
                }
                .disabled((name).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView()
    }
}
