//
//  Color+Extension.swift
//  BottomSheetModifier
//
//  Created by Aysema Çam on 25.09.2024.
//

import SwiftUI

extension Color {
    static var lineViewColor: Color {
        if UITraitCollection.current.userInterfaceStyle == .dark {
            return Color(hex: "#232323")
        } else {
            return Color(hex: "#EDEDED")
        }
    }
    
    static var mainColor: Color {
        if UITraitCollection.current.userInterfaceStyle == .dark {
            return Color(hex: "#0D0F13")
        } else {
            return Color(hex: "#FFFFFF")
        }
    }
    static var bottomSheetTitleColor: Color {
        if UITraitCollection.current.userInterfaceStyle == .dark {
            return Color(hex: "#FFFFFF")
        } else {
            return Color(hex: "#000000")
           
        }
        
    }
    
    static var bottomSheetShadowColor: Color {
        if UITraitCollection.current.userInterfaceStyle == .dark {
            return Color(hex: "#000000")
        } else {
            return Color(hex: "#FFFFFF")
           
        }
    }

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
