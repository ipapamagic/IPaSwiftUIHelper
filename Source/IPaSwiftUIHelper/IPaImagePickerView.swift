//
//  IPaImagePicker.swift
//  IPaSwiftUIHelper
//
//  Created by IPa Chen on 2025/5/4.
//

import SwiftUI
import UIKit

public enum IPaMediaType: String {
    case image = "public.image"
    case movie = "public.movie"
    case livePhoto = "com.apple.live-photo"
    
    public var uti: String {
        return self.rawValue
    }
}

extension View {
    public func pickImage(
        isPresented: Binding<Bool>,
        sourceType: UIImagePickerController.SourceType,
        mediaTypes: [IPaMediaType] = [.image],
        allowsEditing: Bool = false,
        onPickImage: ((UIImage) -> Void)? = nil,
        onPickMediaInfo:  (([UIImagePickerController.InfoKey : Any]) -> Void)? = nil) -> some View {
            Group {
                if sourceType == .photoLibrary {
                    self.sheet(isPresented: isPresented) {
                        self.showPicker(
                            isPresented: isPresented,
                            sourceType: sourceType,
                            mediaTypes: mediaTypes,
                            allowsEditing: allowsEditing,
                            onPickImage: onPickImage,
                            onPickMediaInfo: onPickMediaInfo
                        )
                    }
                }
                else {
                    self.fullScreenCover(isPresented: isPresented, content: {
                        self.showPicker(
                            isPresented: isPresented,
                            sourceType: sourceType,
                            mediaTypes: mediaTypes,
                            allowsEditing: allowsEditing,
                            onPickImage: onPickImage,
                            onPickMediaInfo: onPickMediaInfo
                        ).edgesIgnoringSafeArea(.all)
                    })
                }
            }
        }
    private func showPicker(
        isPresented: Binding<Bool>,
        sourceType: UIImagePickerController.SourceType,
        mediaTypes: [IPaMediaType] = [.image],
        allowsEditing: Bool,
        onPickImage: ((UIImage) -> Void)?,
        onPickMediaInfo:  (([UIImagePickerController.InfoKey : Any]) -> Void)?) -> some View {
            IPaImagePickerView(sourceType: sourceType, allowsEditing: allowsEditing, mediaTypes: mediaTypes, onPick: {
                mediaInfo in
                isPresented.wrappedValue = false
                if let onPickImage = onPickImage, let image = mediaInfo?[.editedImage] as? UIImage ?? mediaInfo?[.originalImage] as? UIImage {
                    onPickImage(image)
                }
                if let onPickMediaInfo = onPickMediaInfo,let mediaInfo = mediaInfo {
                    onPickMediaInfo(mediaInfo)
                }
            })
        }
    
}


public struct IPaImagePickerView: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    let allowsEditing: Bool
    let mediaTypes: [IPaMediaType]
    let onPick: ([UIImagePickerController.InfoKey : Any]?) -> Void
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        picker.mediaTypes = mediaTypes.map(\.uti)
        picker.allowsEditing = allowsEditing
        picker.modalPresentationStyle = .fullScreen
        return picker
    }
    
    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // nothing needed
    }
    
    public class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: IPaImagePickerView
        
        init(_ parent: IPaImagePickerView) {
            self.parent = parent
        }
        
        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            self.parent.onPick(nil)
        }
        
        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            parent.onPick(info)
        }
    }
}

#Preview {
    IPaImagePickerView(sourceType: .photoLibrary, allowsEditing: false, mediaTypes: [.image], onPick: { _ in })
}
