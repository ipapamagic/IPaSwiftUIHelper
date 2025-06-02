//
//  IPaActivityIndicatorView.swift
//  IPaSwiftUIHelper
//
//  Created by IPa Chen on 2021/1/16.
//

import SwiftUI

public struct IPaActivityIndicatorView: UIViewRepresentable {

    @State public var isAnimating: Bool = true
    public let style: UIActivityIndicatorView.Style
    public let tintColor:Color
    public init(style:UIActivityIndicatorView.Style = .large,tintColor:Color = .white) {
        self.style = style
        self.tintColor = tintColor
    }
    public func makeUIView(context: UIViewRepresentableContext<IPaActivityIndicatorView>) -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView(style: style)
        if #available(iOS 14.0, *) {
            view.color = UIColor(tintColor)
        } else {
            // Fallback on earlier versions
            let scanner = Scanner(string: tintColor.description.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
            var hexNumber: UInt64 = 0
            var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0
            
            let result = scanner.scanHexInt64(&hexNumber)
            if result {
                r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                a = CGFloat(hexNumber & 0x000000ff) / 255
            }
            view.color = UIColor(red: r, green: g, blue: b, alpha: a)
        }
        view.hidesWhenStopped = true
        return view
    }
    public func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<IPaActivityIndicatorView>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}
