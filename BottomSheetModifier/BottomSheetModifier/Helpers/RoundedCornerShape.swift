//
//  RoundedCornerShape.swift
//  BottomSheetModifier
//
//  Created by Aysema Çam on 26.09.2024.
//

import SwiftUI

struct RoundedCornerShape: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
