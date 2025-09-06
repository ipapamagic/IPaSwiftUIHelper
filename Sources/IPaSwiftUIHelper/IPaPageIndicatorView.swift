//
//  IPaPageIndicatorView.swift
//  IPaSwiftUIHelper
//
//  Created by IPa Chen on 2025/6/12.
//

import SwiftUI

public struct IPaPageIndicatorView: View {
    public let currentPage: Int
    public let totalPage: Int
    public var activeColor: Color = .black
    public var inactiveColor: Color = .gray
    public var dotSpacing: CGFloat = 8
    public var dotSize: CGFloat = 8
    
    public var body: some View {
        HStack(spacing: dotSpacing) {
            ForEach(0..<totalPage, id: \.self) { index in
                Circle()
                    .frame(width: dotSize, height: dotSize)
                    .foregroundColor(currentPage == index ? activeColor : inactiveColor)
            }
        }
    }
    public init(currentPage: Int, totalPage: Int, activeColor: Color = .black, inactiveColor: Color = .gray, dotSpacing: CGFloat = 8, dotSize: CGFloat = 8) {
        self.currentPage = currentPage
        self.totalPage = totalPage
        self.activeColor = activeColor
        self.inactiveColor = inactiveColor
        self.dotSpacing = dotSpacing
        self.dotSize = dotSize
    }
}

#Preview {
    IPaPageIndicatorView(currentPage: 1, totalPage: 4)
}
