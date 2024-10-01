//
//  ToolButton.swift
//  story_photo_edit
//
//  Created by Aysema Çam on 29.08.2024.
//

import SwiftUI

struct ToolButton: View {
    var iconName: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: iconName)
                .resizable()
                .frame(width: 25, height: 25)
                .padding(2)
                .background(isSelected ? Color.white : Color.clear)
                .foregroundColor(isSelected ? Color.black : Color.white)
                .clipShape(Circle())
        }
        .padding(3)
    }
}



