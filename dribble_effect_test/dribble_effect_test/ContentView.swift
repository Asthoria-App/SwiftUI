//
//  ContentView.swift
//  dribble_effect_test
//
//  Created by Aysema Çam on 12.12.2024.
//

import SwiftUI

struct DribbleEffectView: View {
    let circleSize: CGFloat = 60
    let maxScale: CGFloat = 1.5
    let minScale: CGFloat = 0.5

    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let minCellWidth = screenWidth / 5
            let maxCellWidth = screenWidth / 3
            
            let columns = [
                GridItem(.adaptive(minimum: minCellWidth, maximum: maxCellWidth), spacing: 5)
            ]
            
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 5) {
                    ForEach(0..<50, id: \ .self) { index in
                        GeometryReader { innerGeometry in
                            let itemFrame = innerGeometry.frame(in: .global)
                            let centerX = itemFrame.midX
                            let centerY = itemFrame.midY
                            let scrollViewCenterX = geometry.size.width / 2
                            let scrollViewCenterY = geometry.size.height / 2

                            let distanceX = abs(centerX - scrollViewCenterX)
                            let distanceY = abs(centerY - scrollViewCenterY)
                            let distance = sqrt(distanceX * distanceX + distanceY * distanceY)
                            let scale = max(minScale, maxScale - (distance / 400))

                            Circle()
                                .fill(Color.black)
                                .frame(width: circleSize * scale, height: circleSize * scale)
                                .animation(.spring(), value: scale)
                        }
                        .frame(height: circleSize * maxScale)
                        .offset(x: index % 8 < 4 ? 0 : circleSize / 2)
                    }
                }
                .padding(10)
            }
        }
    }
}

struct ContentView: View {
    var body: some View {
        DribbleEffectView()
    }
}
