//
//  Font+Extensions.swift
//  story_photo_edit
//
//  Created by Aysema Çam on 21.08.2024.
//

import SwiftUI

extension Font {
    static func Roboto(size: CGFloat) -> Font {
        return Font.custom("Roboto-Medium", size: size)
    }
    
    static func GreyQo(size: CGFloat) -> Font {
        return Font.custom("GreyQo-Regular", size: size)
    }
    
    static func GreatVibes(size: CGFloat) -> Font {
        return Font.custom("GreatVibes-Regular", size: size)
    }
    
    static func Righteous(size: CGFloat) -> Font {
        return Font.custom("Righteous-Regular", size: size)
    }
    
    static func Montserrat(size: CGFloat) -> Font {
        return Font.custom("Montserrat-VariableFont_wght", size: size)
    }
    static func Forum(size: CGFloat) -> Font {
        return Font.custom("Forum-Regular.ttf", size: size)
    }
}
enum CustomFont: String {
    case roboto = "Roboto-Medium"
    case greyQo = "GreyQo-Regular"
    case greatVibes = "GreatVibes-Regular"
    case righteous = "Righteous-Regular"
    case montserrat = "Montserrat-VariableFont_wght"
    case forum = "Forum-Regular.ttf"
    
    func toSwiftUIFont(size: CGFloat) -> Font {
        return Font.custom(self.rawValue, size: size)
    }
    
    func toUIFont(size: CGFloat) -> UIFont? {
        return UIFont(name: self.rawValue, size: size)
    }
}
