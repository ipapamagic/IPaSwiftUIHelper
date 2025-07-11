//
//  IPaDocumentPickerView.swift
//  IPaSwiftUIHelper
//
//  Created by IPa Chen on 2025/6/22.
//

import SwiftUI
import UniformTypeIdentifiers
import UIKit

public struct IPaDocumentPickerView: UIViewControllerRepresentable {
    public var contentTypes: [UTType]
    public var allowsMultipleSelection: Bool
    public var onPick: ([URL]) -> Void
    
    public init(contentTypes: [UTType], allowsMultipleSelection: Bool = false, onPick: @escaping ([URL]) -> Void) {
        self.contentTypes = contentTypes
        self.allowsMultipleSelection = allowsMultipleSelection
        self.onPick = onPick
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: contentTypes)
        controller.delegate = context.coordinator
        controller.allowsMultipleSelection = allowsMultipleSelection
        return controller
    }
    
    public func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    public class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: IPaDocumentPickerView
        
        init(_ parent: IPaDocumentPickerView) {
            self.parent = parent
        }
        
        public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.onPick(urls)
            
        }
        
        public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.onPick([])
        }
    }
}

extension View {
    public func pickDocument(
        isPresented: Binding<Bool>,
        contentTypes: [UTType] = [.data],
        allowsMultipleSelection: Bool = false,
        onPick: @escaping ([URL]) -> Void
    ) -> some View {
        self.sheet(isPresented: isPresented) {
            IPaDocumentPickerView(
                contentTypes: contentTypes,
                allowsMultipleSelection: allowsMultipleSelection,
                onPick: { urls in
                    isPresented.wrappedValue = false
                    onPick(urls)
                }
            )
        }
    }
}
