//
//  IPaPhotoPickerView.swift
//  IPaSwiftUIHelper
//
//  Created by IPa Chen on 2025/8/10.
//

import SwiftUI
import UIKit
import PhotosUI

public enum IPaPhotoPickerMediaType {
    case images
    case videos
    case livePhotos
    
    public var filter: PHPickerFilter {
        switch self {
        case .images:
            return .images
        case .videos:
            return .videos
        case .livePhotos:
            return .livePhotos
        }
    }
}

extension View {
    public func pickPhotos(
        isPresented: Binding<Bool>,
        selectionLimit: Int = 1,
        mediaTypes: [IPaPhotoPickerMediaType] = [.images],
        onPickImages: (([UIImage]) -> Void)? = nil,
        onPickResults: (([PHPickerResult]) -> Void)? = nil) -> some View {
            self.sheet(isPresented: isPresented) {
                IPaPhotoPickerView(
                    selectionLimit: selectionLimit,
                    mediaTypes: mediaTypes,
                    onPick: { results in
                        isPresented.wrappedValue = false
                        
                        if let onPickImages = onPickImages {
                            var images: [UIImage] = []
                            let group = DispatchGroup()
                            
                            for result in results {
                                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                                    group.enter()
                                    result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                                        if let image = image as? UIImage {
                                            images.append(image)
                                        }
                                        group.leave()
                                    }
                                }
                            }
                            
                            group.notify(queue: .main) {
                                onPickImages(images)
                            }
                        }
                        
                        if let onPickResults = onPickResults {
                            onPickResults(results)
                        }
                    }
                )
            }
        }
}

public struct IPaPhotoPickerView: UIViewControllerRepresentable {
    let selectionLimit: Int
    let mediaTypes: [IPaPhotoPickerMediaType]
    let onPick: ([PHPickerResult]) -> Void
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = selectionLimit
        
        if mediaTypes.count == 1 {
            configuration.filter = mediaTypes.first?.filter
        } else {
            let filters = mediaTypes.map { $0.filter }
            configuration.filter = PHPickerFilter.any(of: filters)
        }
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    public func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        // nothing needed
    }
    
    public class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: IPaPhotoPickerView
        
        init(_ parent: IPaPhotoPickerView) {
            self.parent = parent
        }
        
        public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.onPick(results)
        }
    }
}

#Preview {
    IPaPhotoPickerView(selectionLimit: 0, mediaTypes: [.images], onPick: { _ in })
}
