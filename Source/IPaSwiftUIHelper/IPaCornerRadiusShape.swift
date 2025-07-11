//
//  IPaCornerRadiusShape.swift
//  IPaSwiftUIHelper
//
//  Created by IPa Chen on 2025/6/11.
//

import SwiftUI

public struct IPaCornerRadiusShape: Shape {
    var radius: CGFloat = 0.0
    var corners: UIRectCorner = .allCorners
    public init(radius: CGFloat, corners: UIRectCorner) {
        self.radius = radius
        self.corners = corners
    }
    public func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

