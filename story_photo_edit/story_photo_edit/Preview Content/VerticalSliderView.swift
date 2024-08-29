//
//  VerticalSliderView.swift
//  story_photo_edit
//
//  Created by Aysema Çam on 29.08.2024.
//

import SwiftUI

struct VerticalSlider: View {
    @Binding var value: CGFloat
    var range: ClosedRange<CGFloat>
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(Color.clear)
                .contentShape(Rectangle())
                .frame(width: 60, height: 240)
                .gesture(DragGesture(minimumDistance: 0).onChanged { value in
                    let percentage = min(max(0, 1 - value.location.y / 200), 1)
                    self.value = percentage * (range.upperBound - range.lowerBound) + range.lowerBound
                })
            
            Capsule()
                .fill(LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.2), Color.white.opacity(0.8)]), startPoint: .bottom, endPoint: .top))
                .frame(width: 10, height: 200 * CGFloat(value / range.upperBound))
                .offset(x: 0)
            
            Capsule()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 10, height: 200)
                .offset(x: 0)
                .mask(Rectangle().frame(height: 200))
        }
        .padding(.top, -280)
        .offset(y: 300)
    }
}
