//
//  TagOverlayView.swift
//  story_photo_edit
//
//  Created by Aysema Çam on 10.09.2024.
//

import Foundation
import SwiftUI

struct TagOverlayView: View {
    @Binding var showTagOverlay: Bool
    @Binding var tagText: String
    
    @State private var textHeight: CGFloat = 30
    @State private var textWidth: CGFloat = 30
    @State private var selectedFont: CustomFont = .roboto
    @State private var fontSize: CGFloat = 24
    @State private var textColor: Color = .black
    @State private var backgroundColor: Color = .white
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    dismissKeyboard()
                    showTagOverlay = false
                }
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            // Kullanıcı renk seçme alanını açabilir
                        }
                    }) {
                        Image(systemName: "paintpalette.fill")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .padding(8)
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {
                        withAnimation {
                            // Font değiştirme işlemi
                        }
                    }) {
                        Image(systemName: "a.circle")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .padding(5)
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {
                        dismissKeyboard()
                        showTagOverlay = false
                    }) {
                        Text("Done")
                            .font(Font.system(size: 21, weight: .medium))
                            .padding(7)
                            .foregroundColor(.white)
                    }
                }
                .padding(.top)
                .padding(.trailing)
                
                Spacer()
                
                // Kullanıcının yazı yazacağı alan
                DynamicHeightTextView(
                    text: $tagText,
                    minHeight: 30,
                    maxHeight: 150,
                    textHeight: $textHeight,
                    textColor: $textColor,
                    backgroundOpacity: .constant(0.7),
                    backgroundColor: $backgroundColor,
                    selectedFont: $selectedFont,
                    textWidth: $textWidth,
                    fontSize: $fontSize
                )
                .frame(width: textWidth, height: textHeight)
                .padding(8)
                .background(Color.clear)
                .cornerRadius(5)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        focusTextView()
                    }
                }
                
                Spacer()
            }
            .padding(.top, 0)
        }
    }
}

struct TagOverlayView_Previews: PreviewProvider {
    @State static var showTagOverlay = true
    @State static var tagText = "Example Tag"
    
    static var previews: some View {
        TagOverlayView(showTagOverlay: $showTagOverlay, tagText: $tagText)
    }
}
