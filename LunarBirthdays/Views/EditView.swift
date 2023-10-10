//
//  EditView.swift
//  LunarBirthdays
//
//  Created by Johnny Jiang on 7/21/23.
//

import SwiftUI
import PhotosUI
import Kingfisher
import CropViewController

struct EditView: View {
    
    @Environment(\.managedObjectContext) var managedObjContext
    @Environment(\.dismiss) var dismiss
    var birthday: Birthday?
    
    @State private var img = ""
    @State private var name = ""
    @State private var date = Date()
    @State private var note = ""
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var imgUI = UIImage()
    @State private var croppedImg = UIImage(named: "Logo") ?? UIImage()
    @State private var isShowingCropView = false
    
    @State private var cal: String = UserDefaults.standard.string(forKey: "calendar") ?? "Lunar"
    let calendars = ["Lunar", "Gregorian"]
    
    @State private var title = ""
    @State private var pickerReset = UUID()
    
    @State private var isPresentingConfirm: Bool = false
    @State private var isDiscardingConfirm: Bool = false
    
    @State private var originalName = ""
    @State private var originalDate = Date()
    @State private var originalNote = ""
    @State private var originalCal = "Lunar"
    
    var body: some View {
        Form {
            VStack {
                if img != "" && (croppedImg.pngData() == UIImage(named: "Logo")?.pngData() ?? UIImage().pngData()) {
                    KFImage(URL(fileURLWithPath: img))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .cornerRadius(10)
                } else {
                    Image(uiImage: croppedImg)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .cornerRadius(20)
                }
                PhotosPicker("Change-Image", selection: $selectedItem, matching: .images)
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
                    ForEach(calendars, id: \.self) { calendarType in
                        Text(LocalizedStringKey(calendarType))
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
                        Button("Are-You-Sure", role: .destructive) {
                            DataController.shared.deleteBirthday(birthday: birthday!, context: managedObjContext)
                            clearNavigationPath()
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .gesture(DragGesture().onChanged { _ in
            UIApplication.shared.dismissKeyboard()
        })
        .onChange(of: selectedItem) { _ in
            Task {
                if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data) {
                        isShowingCropView.toggle()
                        imgUI = uiImage
                        return
                    }
                }
                
                print("Failed")
            }
        }
        .onAppear {
            img = birthday?.img ?? ""
            name = birthday?.name ?? ""
            date = birthday?.date ?? Date()
            note = birthday?.note ?? ""
            cal = birthday?.cal ?? cal
            
            originalName = name
            originalDate = date
            originalNote = note
            originalCal = cal
        }
        .navigationBarBackButtonHidden(true)
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
                    if img != "" && (croppedImg.pngData() == UIImage(named: "Logo")?.pngData() ?? UIImage().pngData()) {
                        
                    } else {
                        if let imagePath = DataController.shared.saveImage(croppedImg, withFilename: "\(UUID()).jpg") {
                            img = imagePath
                        }
                    }
                    if birthday != nil {
                        DataController.shared.editBirthday(birthday: birthday!, img: img, name: name, date: date, note: note, cal: cal, context: managedObjContext)
                    } else {
                        DataController.shared.addBirthday(img: img, name: name, date: date, note: note, cal: cal, context: managedObjContext)
                    }
                    dismiss()
                }
                .disabled((name).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .confirmationDialog("Discard", isPresented: $isDiscardingConfirm) {
            Button("Discard-Changes", role: .destructive) {
                dismiss()
            }
        }
        .sheet(isPresented: $isShowingCropView) {
            CropImageViewController(image: $imgUI, cropped: $croppedImg, isPresented: $isShowingCropView)
        }
    }
    private func dataChange() -> Bool {
        return !(imgUI == UIImage() &&
                 name == originalName &&
                 date == originalDate &&
                 note == originalNote &&
                 cal == originalCal)
    }
}
