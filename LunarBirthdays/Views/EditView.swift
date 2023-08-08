//
//  EditView.swift
//  LunarBirthdays
//
//  Created by Johnny Jiang on 7/21/23.
//

import SwiftUI
import PhotosUI
import Kingfisher
import PhotoSelectAndCrop

struct EditView: View {
    
    @Environment(\.managedObjectContext) var managedObjContext
    @Environment(\.dismiss) var dismiss
    @StateObject private var dataController = DataController()
    
    var birthday: Birthday?
    
    @State private var img = ""
    @State private var name = ""
    @State private var date = Date()
    @State private var note = ""
    
    @State private var avatarItem: PhotosPickerItem?
    @State private var imgUI = UIImage()
    
    @State private var cal: String = UserDefaults.standard.string(forKey: "calendar") ?? "Lunar"
    let calendars = ["Lunar", "Gregorian"]
    
    @State private var title = ""
    @State private var pickerReset = UUID()
    
    @State private var isPresentingConfirm: Bool = false
    @State private var isDiscardingConfirm: Bool = false
    
    @State private var originalImg = UIImage()
    @State private var originalName = ""
    @State private var originalDate = Date()
    @State private var originalNote = ""
    @State private var originalCal = "Lunar"
    
    var body: some View {
        Form {
            VStack {
                KFImage(URL(fileURLWithPath: img))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
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
                
            }
            Section(header: Text("Birthday")) {
                Picker("Calendar", selection: $cal) {
                    ForEach(calendars, id: \.self) {
                        Text($0)
                    }
                }
                WheelDatePicker(selectedDate: $date)
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
                    .confirmationDialog("Delete", isPresented: $isPresentingConfirm) {
                        Button("Are you sure?", role: .destructive) {
                            dataController.deleteBirthday(birthday: birthday!, context: managedObjContext)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .gesture(DragGesture().onChanged { _ in
            UIApplication.shared.dismissKeyboard()
        })
        .onChange(of: avatarItem) { _ in
            Task {
                if let data = try? await avatarItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data),
                   let imagePath = dataController.saveImage(imgUI, withFilename: "\(UUID()).jpg") {
                    img = imagePath
                    imgUI = uiImage
                } else {
                    print("Failed to load image")
                }
            }
        }
        .onAppear {
            img = birthday?.img ?? ""
            name = birthday?.name ?? ""
            date = birthday?.date ?? Date()
            note = birthday?.note ?? ""
            cal = birthday?.cal ?? cal
            
            imgUI = loadImage(from: img)
            originalImg = imgUI
            originalName = name
            originalDate = date
            originalNote = note
            originalCal = cal
        }
        .onDisappear {
            dataController.clearDocumentsDirectory()
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button("Cancel") {
                    if dataChange() {
                        isDiscardingConfirm = true
                    } else {
                        dismiss()
                    }
                }
            }
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button("Save") {
                    if birthday != nil {
                        dataController.editBirthday(birthday: birthday!, img: img, name: name, date: date, note: note, cal: cal, context: managedObjContext)
                    } else {
                        dataController.addBirthday(img: img, name: name, date: date, note: note, cal: cal, context: managedObjContext)
                    }
                    dismiss()
                }
                .disabled((name).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .confirmationDialog("Discard?", isPresented: $isDiscardingConfirm) {
            Button("Discard Changes?", role: .destructive) {
                dismiss()
            }
        }
    }
    private func dataChange() -> Bool {
        return !(imgUI == originalImg &&
                 name == originalName &&
                 date == originalDate &&
                 note == originalNote &&
                 cal == originalCal)
    }
    func loadImage(from path: String?) -> UIImage {
        guard let path = path, let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            return UIImage()
        }
        return UIImage(data: data) ?? UIImage()
    }
    func listFilesInDirectory(_ directoryURL: URL) {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
            for fileURL in fileURLs {
                print("File: \(fileURL.lastPathComponent)")
            }
        } catch {
            print("Error listing files: \(error)")
        }
    }
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView()
    }
}
