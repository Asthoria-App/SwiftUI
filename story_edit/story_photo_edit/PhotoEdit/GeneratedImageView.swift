//
//  GeneratedImageView.swift
//  story_photo_edit
//
//  Created by Aysema Çam on 1.10.2024.
//

import SwiftUI

struct GeneratedImageView: View {
    var image: UIImage?
    var tagPositions: [(position: CGPoint, index: Int)]
    var locationPositions: [(position: CGPoint, index: Int)]
    
    var body: some View {
        ZStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .edgesIgnoringSafeArea(.all)
            } else {
                Text("No image generated")
            }

        }
        .onAppear {
            print(tagPositions, locationPositions, "positions")
        }
    }
}
