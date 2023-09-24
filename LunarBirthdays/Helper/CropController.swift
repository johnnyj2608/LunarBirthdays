//
//  CropController.swift
//  LunarBirthdays
//
//  Created by Johnny Jiang on 9/17/23.
//

import SwiftUI
import CropViewController

struct CropImageViewController: UIViewControllerRepresentable {
    @Binding var image: UIImage
    @Binding var cropped: UIImage
    @Binding var isPresented: Bool

    func makeUIViewController(context: Context) -> UINavigationController {
        let cropViewController = CropViewController(image: image)
        cropViewController.doneButtonTitle = "Done"
        cropViewController.cancelButtonTitle = "Cancel"
        cropViewController.rotateButtonsHidden = true
        cropViewController.rotateClockwiseButtonHidden = true
        cropViewController.toolbarPosition = .top
        cropViewController.delegate = context.coordinator
        
        cropViewController.aspectRatioPreset = .presetSquare
        cropViewController.aspectRatioLockEnabled = true
        cropViewController.aspectRatioLockDimensionSwapEnabled = false
        cropViewController.resetAspectRatioEnabled = false
        
        return UINavigationController(rootViewController: cropViewController)
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // Update the view controller if needed
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, CropViewControllerDelegate {
        var parent: CropImageViewController

        init(_ parent: CropImageViewController) {
            self.parent = parent
        }

        func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
            parent.cropped = image
            parent.isPresented = false
        }

        func cropViewControllerDidCancel(_ cropViewController: CropViewController) {
            parent.isPresented = false
        }
    }
}
