//
//  IPaVideoClipView.swift
//  IPaSwiftUIHelper
//
//  Created by IPa Chen on 2025/6/20.
//


import SwiftUI
import AVFoundation
import IPaLog
public struct IPaVideoClipView<Content: View>: View {
    let urlString: String
    let defaultImage: UIImage?
    let content: (Image) -> Content
    @State private var uiImage: UIImage?
    
    public init(urlString: String,
                default defaultImage: UIImage? = nil,
                @ViewBuilder content: @escaping (Image) -> Content) {
        self.urlString = urlString
        self.defaultImage = defaultImage
        self.content = content
    }
    
    public var body: some View {
        Group {
            if let uiImage = uiImage {
                content(Image(uiImage: uiImage))
            } else if let defaultImage = defaultImage {
                content(Image(uiImage: defaultImage))
            } else {
                EmptyView()
            }
        }
        .onAppear {
            loadThumbnail()
        }
    }
    
    private func loadThumbnail() {
        guard let url = URL(string: urlString) else {
            return
        }
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 1, preferredTimescale: 600)
        
        DispatchQueue.global().async {
            do {
                let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
                let image = UIImage(cgImage: cgImage)
                DispatchQueue.main.async {
                    self.uiImage = image
                }
            } catch {
                IPaLog("⚠️ IPaVideoClipView failed to load thumbnail: \(error)")
            }
        }
    }
}

