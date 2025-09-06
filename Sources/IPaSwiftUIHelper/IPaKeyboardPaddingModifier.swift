//
//  IPaKeyboardPaddingModifier.swift
//  IPaSwiftUIHelper
//
//  Created by IPa Chen on 2021/1/16.
//

import SwiftUI
import Combine

struct IPaKeyboardPaddingModifier: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0
    @State private var cancellable: AnyCancellable?
    
    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight)
            .onAppear {
                let willShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
                    .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
                    .map { $0.height }
                
                let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
                    .map { _ in CGFloat(0) }
                
                cancellable = Publishers.Merge(willShow, willHide)
                    .receive(on: RunLoop.main)
                    .assign(to: \.keyboardHeight, on: self)
            }
            .onDisappear {
                cancellable?.cancel()
            }
    }
}

extension View {
    public func keyboardPadding() -> some View {
        self.modifier(IPaKeyboardPaddingModifier())
    }
}
