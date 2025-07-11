//
//  IPaUrlImage.swift
//  IPaSwiftUIHelper
//
//  Created by IPa Chen on 2025/6/19.
//


import SwiftUI
import IPaDownloadManager

public struct IPaUrlImage<Content: View>: View {
    @State private var downloadedImage: UIImage? = nil
    @Binding public var url: URL?
    public var defaultImage: UIImage?
    let content: (Image) -> Content
    
    public init(
        urlString: String,
        default image: UIImage? = nil,
        @ViewBuilder content: @escaping (Image) -> Content
    ) {
        self.init(urlString: .constant(urlString), default: image, content: content)
    }
    
    public init(
        url: URL?,
        default image: UIImage? = nil,
        @ViewBuilder content: @escaping (Image) -> Content
    ) {
        self.init(url: .constant(url), default: image, content: content)
    }
    
    public init(
        urlString: Binding<String>,
        default image: UIImage? = nil,
        @ViewBuilder content: @escaping (Image) -> Content
    ) {
        let boundUrl = Binding<URL?>(
            get: { URL(string: urlString.wrappedValue) },
            set: { _ in }
        )
        self.init(url: boundUrl, default: image, content: content)
    }
    
    public init(
        url: Binding<URL?>,
        default image: UIImage? = nil,
        @ViewBuilder content: @escaping (Image) -> Content
    ) {
        self._url = url
        self.defaultImage = image
        self.content = content
        
    }
    
    private func downloadImageIfNeeded() {
        guard let url = url, downloadedImage == nil else { return }
        IPaDownloadManager.shared.download(from: url) { result in
            if let locationUrl = result.locationUrl,
               let image = UIImage(contentsOfFile: locationUrl.path) {
                self.downloadedImage = image
            }
        }
    }
    
    public var body: some View {
        let image = Image(uiImage: downloadedImage ?? defaultImage ?? UIImage())
        return content(image)
            .onAppear {
                downloadImageIfNeeded()
            }
            .onChange(of: url) { _ in
                downloadImageIfNeeded()
            }
    }
}
