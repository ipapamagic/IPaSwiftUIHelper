//
//  IPaImagePicker.swift
//  IPaSwiftUIHelper
//
//  Created by IPa Chen on 2025/5/4.
//

import SwiftUI
import UIKit

extension View {
    public func takePhoto(
        isPresented: Binding<Bool>,
        allowsEditing: Bool = false,
        onTakePhoto: ((UIImage) -> Void)? = nil,
        onMediaInfo:  (([UIImagePickerController.InfoKey : Any]) -> Void)? = nil) -> some View {
            Group {
               
                self.fullScreenCover(isPresented: isPresented, content: {
                    self.showPicker(
                        isPresented: isPresented,
                        allowsEditing: allowsEditing,
                        onTakePhoto: onTakePhoto,
                        onMediaInfo: onMediaInfo
                    ).edgesIgnoringSafeArea(.all)
                })
            
            }
        }
    private func showPicker(
        isPresented: Binding<Bool>,
        allowsEditing: Bool,
        onTakePhoto: ((UIImage) -> Void)?,
        onMediaInfo:  (([UIImagePickerController.InfoKey : Any]) -> Void)?) -> some View {
            IPaPhotoTakerView(allowsEditing: allowsEditing, onTake: {
                mediaInfo in
                isPresented.wrappedValue = false
                if let onTakePhoto = onTakePhoto, let image = mediaInfo?[.editedImage] as? UIImage ?? mediaInfo?[.originalImage] as? UIImage {
                    onTakePhoto(image)
                }
                if let onMediaInfo = onMediaInfo,let mediaInfo = mediaInfo {
                    onMediaInfo(mediaInfo)
                }
            })
        }
    
}


public struct IPaPhotoTakerView: UIViewControllerRepresentable {
    let allowsEditing: Bool
    let onTake: ([UIImagePickerController.InfoKey : Any]?) -> Void
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.allowsEditing = allowsEditing
        picker.modalPresentationStyle = .fullScreen
        return picker
    }
    
    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // nothing needed
    }
    
    public class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: IPaPhotoTakerView
        
        init(_ parent: IPaPhotoTakerView) {
            self.parent = parent
        }
        
        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            self.parent.onTake(nil)
        }
        
        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            parent.onTake(info)
        }
    }
}

#Preview {
    IPaPhotoTakerView( allowsEditing: false, onTake: { _ in })
}
