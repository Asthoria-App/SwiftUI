//
//  TextOverlayView.swift
//  story_photo_edit
//
//  Created by Aysema Çam on 29.08.2024.
//

import SwiftUI
import Combine
struct OverlayView: View {
    
    @Binding var showOverlay: Bool
    @State var userText: String = ""
    @Binding var draggableTexts: [DraggableText]
    @Binding var globalIndex: CGFloat
    @Binding var selectedTextIndex: Int?
    
    @State var textColor: Color = .white
    @State var backgroundColor: Color = .clear
    @State var backgroundOpacity: CGFloat = 0.0
    @State var selectedFont: CustomFont = .roboto
    @State var originalTextColor: Color = .clear
    @State var fontSize: CGFloat = 64
    @State private var textHeight: CGFloat = 30
    @State private var textWidth: CGFloat = 30
    @State private var keyboardHeight: CGFloat = 0
    @State private var showFontCollection: Bool = false
    @State private var showColorCollection: Bool = true
    @State private var isEditing: Bool = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    dismissKeyboard()
                    saveAndCloseOverlay()
                    showOverlay = false
                }
            
            VStack {
                HStack {
                    VStack {
                        ZStack(alignment: .bottom) {
                            Rectangle()
                                .fill(Color.clear)
                                .contentShape(Rectangle())
                                .frame(width: 60, height: 240)
                                .gesture(DragGesture(minimumDistance: 0).onChanged { value in
                                    let percentage = min(max(0, 1 - value.location.y / 200), 1)
                                    fontSize = percentage * 70 + 10
                                })
                            
                            Capsule()
                                .fill(LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.2), Color.white.opacity(0.8)]), startPoint: .bottom, endPoint: .top))
                                .frame(width: 10, height: 200 * CGFloat(fontSize / 80))
                                .offset(x: 0)
                            
                            Capsule()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 10, height: 200)
                                .offset(x: 0)
                                .mask(Rectangle().frame(height: 200))
                        }
                        .padding(.top, -280)
                        .offset(y: 300)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            showFontCollection = false
                            showColorCollection = true
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
                            showFontCollection = true
                            showColorCollection = false
                        }
                    }) {
                        Image(systemName: "a.circle")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .padding(5)
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {
                        withAnimation {
                            toggleBackgroundAndTextColors()
                        }
                    }) {
                        Image(systemName: "square.text.square.fill")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .padding(5)
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {
                        dismissKeyboard()
                        saveAndCloseOverlay()
                        showOverlay = false
                    }) {
                        Text("Done")
                            .font(Font.system(size: 21, weight: .medium))
                            .padding(7)
                            .foregroundColor(.white)
                    }
                }
                .padding(.top)
                .padding(.trailing)
                .frame(maxWidth: .infinity)
                .background(Color.clear)
                
                Spacer()
                
                DynamicHeightTextView(
                    text: $userText,
                    minHeight: 30,
                    maxHeight: 150,
                    textHeight: $textHeight,
                    textColor: $textColor,
                    backgroundOpacity: $backgroundOpacity,
                    backgroundColor: $backgroundColor,
                    selectedFont: $selectedFont,
                    textWidth: $textWidth,
                    fontSize: $fontSize,
                    lastScale: .constant(1.0)
                )
                .frame(width: textWidth, height: textHeight)
                .padding(8)
                .background(Color.clear)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        focusTextView()
                        if let index = selectedTextIndex {
                            isEditing = true
                            loadExistingText(index: index)
                        } else {
                            isEditing = false
                        }
                    }
                }
                
                ZStack {
                    if showColorCollection {
                        ColorSelectionView(selectedColor: $textColor, originalColor: $originalTextColor)
                            .padding(.horizontal)
                            .frame(height: 50)
                            .background(Color.white.opacity(0.0))
                            .cornerRadius(10)
                            .padding(.bottom, 5)
                            .transition(.opacity)
                    }
                    
                    if showFontCollection {
                        FontCollectionView(selectedFont: $selectedFont)
                            .padding(.horizontal)
                            .frame(height: 35)
                            .background(Color.white.opacity(0.0))
                            .cornerRadius(10)
                            .padding(.bottom, 5)
                            .transition(.opacity)
                    }
                }
                .animation(.easeInOut, value: showColorCollection || showFontCollection)
            }
            .padding(.top, 0)
        }
    }
    
    private func loadExistingText(index: Int) {
        let selectedText = draggableTexts[index]
        userText = selectedText.text
        textColor = selectedText.textColor
        backgroundColor = selectedText.backgroundColor
        backgroundOpacity = selectedText.backgroundOpacity
        selectedFont = selectedText.font
        fontSize = selectedText.fontSize
        originalTextColor = selectedText.originalTextColor
    }
    
    private func toggleBackgroundAndTextColors() {
        if textColor == .white && backgroundOpacity == 0.0 {
            backgroundColor = .black
            backgroundOpacity = 0.7
            
        } else if backgroundColor == .black && backgroundOpacity == 0.7 && textColor == .white {
            backgroundColor = .white
            textColor = .black
            backgroundOpacity = 0.7
            
        } else if  backgroundColor == .white && textColor == .black && backgroundOpacity == 0.7 {
            textColor = .white
            backgroundOpacity = 0.0
            
        } else if backgroundOpacity == 0.0 {
            backgroundOpacity = 0.7
            backgroundColor = .white
        } else if backgroundOpacity == 0.7
                    
                    && backgroundColor == .white {
            backgroundColor = textColor
            textColor = .white
        } else {
            
            textColor = originalTextColor
            backgroundOpacity = 0.0
        }
    }
    
    private func saveAndCloseOverlay() {
        if userText.count > 1 {
            if let index = selectedTextIndex {
                draggableTexts[index].text = userText
                draggableTexts[index].textColor = textColor
                draggableTexts[index].backgroundColor = backgroundOpacity == 0.0 ? .clear : backgroundColor
                draggableTexts[index].backgroundOpacity = backgroundOpacity
                draggableTexts[index].font = selectedFont
                draggableTexts[index].fontSize = fontSize
                draggableTexts[index].originalTextColor = originalTextColor
            } else {
                let newDraggableText = DraggableText(
                    text: userText,
                    position: .zero,
                    scale: 1.0,
                    angle: .zero,
                    textColor: textColor,
                    backgroundColor: backgroundOpacity == 0.0 ? .clear : backgroundColor,
                    backgroundOpacity: backgroundOpacity,
                    font: selectedFont,
                    fontSize: fontSize,
                    originalTextColor: originalTextColor,
                    zIndex: globalIndex,
                    lastScale: 1.0
                )
                globalIndex += 1
                draggableTexts.append(newDraggableText)
            }
        }
        showOverlay = false
    }
}

struct DynamicHeightTextView: UIViewRepresentable {
    @Binding var text: String
    var minHeight: CGFloat
    var maxHeight: CGFloat
    @Binding var textHeight: CGFloat
    @Binding var textColor: Color
    @Binding var backgroundOpacity: CGFloat
    @Binding var backgroundColor: Color
    @Binding var selectedFont: CustomFont
    @Binding var textWidth: CGFloat
    @Binding var fontSize: CGFloat
    @Binding var lastScale: CGFloat
    
    @State private var currentScale: CGFloat = 1.0
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: DynamicHeightTextView
        
        init(_ parent: DynamicHeightTextView) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            let maxWidth = UIScreen.main.bounds.width * 0.9
            let size = textView.sizeThatFits(CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude))
            self.parent.textHeight = max(self.parent.minHeight, min(size.height, self.parent.maxHeight))
            self.parent.text = textView.text
            DispatchQueue.main.async {
                self.parent.textWidth = min(size.width, maxWidth)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isScrollEnabled = true
        textView.delegate = context.coordinator
        textView.text = text
        textView.backgroundColor = UIColor(backgroundColor).withAlphaComponent(backgroundOpacity)
        textView.layer.masksToBounds = true
        textView.layer.cornerRadius = 5
        textView.textColor = UIColor(textColor)
        textView.becomeFirstResponder()
        
        if let uiFont = selectedFont.toUIFont(size: fontSize) {
            textView.font = uiFont
        } else {
            textView.font = UIFont.systemFont(ofSize: fontSize)
        }
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        uiView.textColor = UIColor(textColor)
        uiView.backgroundColor = UIColor(backgroundColor).withAlphaComponent(backgroundOpacity)
        
        if let uiFont = selectedFont.toUIFont(size: fontSize) {
            uiView.font = uiFont
        } else {
            uiView.font = UIFont.systemFont(ofSize: fontSize)
        }
        
        let maxWidth = UIScreen.main.bounds.width * 0.9
        let size = uiView.sizeThatFits(CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude))
        
        DispatchQueue.main.async {
            self.textHeight = max(self.minHeight, min(size.height, self.maxHeight))
            self.textWidth = min(size.width, maxWidth)
        }
    }
}


struct ColorSelectionView: View {
    @Binding var selectedColor: Color
    @Binding var originalColor: Color
    
    var onColorSelected: ((Color) -> Void)? = nil
    
    let colors: [Color] = [
        .red, .green, .blue, .yellow, .orange, .purple,
        .pink, .cyan, .mint, .teal, .indigo, .brown,
        .gray, .black, .white
    ]
    
    var body: some View {
        HStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(colors, id: \.self) { color in
                        ZStack {
                            Circle()
                                .fill(color)
                                .frame(width: 25, height: 25)
                                .overlay(
                                    Circle()
                                        .stroke(
                                            color == selectedColor ? Color.white : Color.white.opacity(0.5),
                                            lineWidth: color == selectedColor ? 3 : 1.5
                                        )
                                )
                                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 0)
                        }
                        .onTapGesture {
                            withAnimation {
                                selectedColor = color
                                originalColor = color
                                onColorSelected?(color)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
        }
    }
}

struct FontCollectionView: View {
    @Binding var selectedFont: CustomFont
    
    let fonts: [CustomFont] = [
        .roboto,
        .greyQo,
        .greatVibes,
        .righteous
    ]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(fonts, id: \.self) { font in
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(0.6))
                            .frame(width: 35, height: 35)
                        
                        Text("Aa")
                            .font(font.toSwiftUIFont(size: 24))
                            .foregroundColor(.white)
                            .padding(2)
                    }
                    .onTapGesture {
                        selectedFont = font
                    }
                }
            }
            .padding()
        }
    }
}

func dismissKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}

func focusTextView() {
    UIApplication.shared.sendAction(#selector(UIResponder.becomeFirstResponder), to: nil, from: nil, for: nil)
}
