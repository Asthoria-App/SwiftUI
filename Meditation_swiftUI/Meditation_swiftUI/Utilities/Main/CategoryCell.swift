//
//  CategoryCell.swift
//  Meditation_swiftUI
//
//  Created by Aysema Çam on 6.08.2024.
//

import SwiftUI

struct CategoryCell: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(icon)
                .resizable()
                .frame(width: 20, height: 20)
                .clipShape(Circle())
            Text(title)
                .foregroundColor(.white)
                .font(.headline)
                .padding(.leading, 0)
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)

        .background(Color.gray.opacity(0.2))
        .cornerRadius(20)
        .frame(width: 200, height: 60)
    }
}
