//
//  SecondTopView.swift
//  Meditation_swiftUI
//
//  Created by Aysema Çam on 6.08.2024.
//

import Foundation
import SwiftUI

struct SecondTopView: View {
    var title: String

    var body: some View {
        HStack {
       
            
            Text(title)
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Spacer()

        

        }
        .background(Color.black)
        .padding()
    }
}

