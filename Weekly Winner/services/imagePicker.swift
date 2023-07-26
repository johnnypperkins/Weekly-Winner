//
//  imagePicker.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 7/25/23.
//


import SwiftUI

struct imagePickerCamera: UIViewControllerRepresentable {
    @Binding var isShown: Bool
    @Binding var image: UIImage?
    var sourceType: UIImagePickerController.SourceType = .camera

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<imagePickerCamera>) {}

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(isShown: $isShown, image: $image)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        @Binding var isShown: Bool
        @Binding var image: UIImage?

        init(isShown: Binding<Bool>, image: Binding<UIImage?>) {
            _isShown = isShown
            _image = image
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let uiImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            image = uiImage
            isShown = false
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            isShown = false
        }
    }
}

import PhotosUI

struct imagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {

    }
    func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }

        class Coordinator: NSObject, PHPickerViewControllerDelegate {
            let parent: imagePicker

            init(_ parent: imagePicker) {
                self.parent = parent
            }

            func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
                picker.dismiss(animated: true)

                guard let provider = results.first?.itemProvider else { return }

                if provider.canLoadObject(ofClass: UIImage.self) {
                    provider.loadObject(ofClass: UIImage.self) { image, _ in
                        self.parent.image = image as? UIImage
                    }
                }
            }
        }
    }

