//
//  IPaMediaPickerView.swift
//  IPaSwiftUIHelper
//
//  Created by IPa Chen on 2025/8/10.
//

import SwiftUI
import UIKit
import PhotosUI

public enum IPaMediaPickerType {
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
    public func pickMedias(
        isPresented: Binding<Bool>,
        selectionLimit: Int = 1,
        mediaTypes: [IPaMediaPickerType] = [.images],
        onPickResults: @escaping ([PHPickerResult]) -> Void) -> some View {
            self.sheet(isPresented: isPresented) {
                IPaMediaPickerView(
                    selectionLimit: selectionLimit,
                    mediaTypes: mediaTypes,
                    onPick: { results in
                        isPresented.wrappedValue = false
                        onPickResults(results)
                    }
                )
            }
        }
    public func pickPhotos(isPresented: Binding<Bool>,selectionLimit:Int = 1,onPickPhoto: @escaping ([UIImage])-> Void) -> some View {
        return self.pickMedias(isPresented: isPresented,selectionLimit: selectionLimit,mediaTypes: [.images]) { results in
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
                onPickPhoto(images)
            }
        
        }
    }
    
    public func pickLivePhotos(isPresented: Binding<Bool>, selectionLimit: Int = 1, onPickLivePhoto: @escaping ([PHLivePhoto]) -> Void) -> some View {
        return self.pickMedias(isPresented: isPresented, selectionLimit: selectionLimit, mediaTypes: [.livePhotos]) { results in
            var livePhotos: [PHLivePhoto] = []
            let group = DispatchGroup()
            for result in results {
                if result.itemProvider.canLoadObject(ofClass: PHLivePhoto.self) {
                    group.enter()
                    result.itemProvider.loadObject(ofClass: PHLivePhoto.self) { (livePhoto, error) in
                        if let livePhoto = livePhoto as? PHLivePhoto {
                            livePhotos.append(livePhoto)
                        }
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: .main) {
                onPickLivePhoto(livePhotos)
            }
        }
    }
    
    public func pickVideos(isPresented: Binding<Bool>, selectionLimit: Int = 1, onPickVideo: @escaping ([URL]) -> Void) -> some View {
        return self.pickMedias(isPresented: isPresented, selectionLimit: selectionLimit, mediaTypes: [.videos]) { results in
            var videoURLs: [URL] = []
            let group = DispatchGroup()
            for result in results {
                if result.itemProvider.hasItemConformingToTypeIdentifier("public.movie") {
                    group.enter()
                    result.itemProvider.loadFileRepresentation(forTypeIdentifier: "public.movie") { (url, error) in
                        if let url = url {
                            videoURLs.append(url)
                        }
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: .main) {
                onPickVideo(videoURLs)
            }
        }
    }
    
    
}

public struct IPaMediaPickerView: UIViewControllerRepresentable {
    let selectionLimit: Int
    let mediaTypes: [IPaMediaPickerType]
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
        let parent: IPaMediaPickerView
        
        init(_ parent: IPaMediaPickerView) {
            self.parent = parent
        }
        
        public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.onPick(results)
        }
    }
}

#Preview {
    IPaMediaPickerView(selectionLimit: 0, mediaTypes: [.images], onPick: { _ in })
}
