//
//  LineView.swift
//  BottomSheetModifier
//
//  Created by Aysema Çam on 25.09.2024.
//

import SwiftUI

struct LineView: View {
    var width: CGFloat
    var height: CGFloat = 2
    var color: Color = .lineViewColor
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: width, height: height)
            .cornerRadius(height / 2)
    }
}
