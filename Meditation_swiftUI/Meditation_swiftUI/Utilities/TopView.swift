//
//  TopView.swift
//  Meditation_swiftUI
//
//  Created by Aysema Çam on 6.08.2024.
//

import Foundation
import SwiftUI

struct TopView: View {
    var title: String

    var body: some View {
        ZStack {
            HStack {
                Spacer()

                Button(action: {
                    // Action for notification button
                }) {
                    Image(systemName: "bell")
                        .font(.title3)
                        .padding(5)
                        .foregroundColor(.white)
                        .background(Color.white.opacity(0.16))
                        .clipShape(Circle())
                }

                Button(action: {
                }) {
                    Image(systemName: "magnifyingglass")
                        .font(.title3)
                        .padding(5)
                        .foregroundColor(.white)
                        .background(Color.white.opacity(0.15))
                        .clipShape(Circle())
                }
            }
            .padding(.trailing)

            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
        .background(Color.black)
        .padding()
    }
}

struct TopView_Previews: PreviewProvider {
    static var previews: some View {
        TopView(title: "Sleep")
    }
}
