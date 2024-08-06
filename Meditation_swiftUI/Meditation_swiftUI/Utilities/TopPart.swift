//
//  TopPart.swift
//  Meditation_swiftUI
//
//  Created by Aysema Çam on 6.08.2024.
//

import Foundation
import SwiftUI

struct TopPart: View {

    var body: some View {
        VStack(spacing: 0, content: {
            /*@START_MENU_TOKEN@*/Text("Placeholder")/*@END_MENU_TOKEN@*/
        
            TopView(title: "Sleep")
                 .frame(height: 40)
             SecondTopView(title: "Sleep")
                 .frame(height: 40)

 Spacer()
         
        })
        .background(Color.black)
        .padding()
    }
}
struct TopPart_Previews: PreviewProvider {
    static var previews: some View {
        TopPart()
    }
}
