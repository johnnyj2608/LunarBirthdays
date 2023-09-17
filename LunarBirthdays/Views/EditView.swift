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
    var navTitle: String?
    
    @State private var img = ""
    @State private var name = ""
    @State private var date = Date()
    @State private var note = ""
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var imgUI: UIImage?
    @State private var isShowingCropView = false
    
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
                /*KFImage(URL(fileURLWithPath: img))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)*/
                Image(uiImage: imgUI ?? UIImage())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                PhotosPicker("Change Image", selection: $selectedItem, matching: .images)
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
                            DataController().deleteBirthday(birthday: birthday!, context: managedObjContext)
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
            /*
            originalImg = imgUI ?? UIImage()
            originalName = name
            originalDate = date
            originalNote = note
            originalCal = cal */
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle(navTitle ?? "Edit")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button("Cancel") {
                    /*if dataChange() {
                        isDiscardingConfirm = true
                    } else {*/
                        dismiss()
                    //}
                }
            }
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button("Save") {
                    if birthday != nil {
                        DataController().editBirthday(birthday: birthday!, img: img, name: name, date: date, note: note, cal: cal, context: managedObjContext)
                    } else {
                        DataController().addBirthday(img: img, name: name, date: date, note: note, cal: cal, context: managedObjContext)
                    }
                    dismiss()
                }
                .disabled((name).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }/*
        .confirmationDialog("Discard?", isPresented: $isDiscardingConfirm) {
            Button("Discard Changes?", role: .destructive) {
                dismiss()
            }
        }*/
        .sheet(isPresented: $isShowingCropView) {
            CropImageViewController(image: $imgUI, isPresented: $isShowingCropView)
        }
    }/*
    private func dataChange() -> Bool {
        return !(imgUI == originalImg &&
                 name == originalName &&
                 date == originalDate &&
                 note == originalNote &&
                 cal == originalCal)
    }*/
}
