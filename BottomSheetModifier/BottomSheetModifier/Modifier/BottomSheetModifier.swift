//
//  BottomSheetModifier.swift
//  BottomSheetModifier
//
//  Created by Aysema Çam on 25.09.2024.
//

import SwiftUI

struct BottomSheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    
    let height: CGFloat
    let title: String
    let backgroundColor: Color
    let backgroundImage: Image?
    let backgroundBlur: Bool
    let showLines: Bool
    let sheetContent: () -> SheetContent
    
    @State private var dragOffset: CGFloat = 0
    @State private var lastDragPositions: [CGFloat] = []
    
    init(isPresented: Binding<Bool>,
         height: CGFloat,
         title: String,
         backgroundColor: Color,
         backgroundImage: Image? = nil,
         backgroundBlur: Bool = false,
         showLines: Bool = true,
         @ViewBuilder sheetContent: @escaping () -> SheetContent) {
        self._isPresented = isPresented
        self.height = height
        self.title = title
        self.backgroundColor = backgroundColor
        self.backgroundImage = backgroundImage
        self.backgroundBlur = backgroundBlur
        self.showLines = showLines
        self.sheetContent = sheetContent
    }
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if isPresented {
                overlayBackgroundView
                bottomSheetView
            }
        }
    }
    
    private var overlayBackgroundView: some View {
        Color.black.opacity(0.3)
            .ignoresSafeArea()
            .onTapGesture {
                dismissSheet()
            }
    }
    
    private var bottomSheetView: some View {
        VStack {
            Spacer()
            VStack(spacing: 0) {
                if showLines { topLineView }
                if !title.isEmpty { titleView }
                if showLines { bottomLineView }
                sheetContent()
            }
            .frame(width: UIScreen.main.bounds.width, height: height, alignment: .top)
            .background(backgroundView)
            .clipShape(RoundedCornerShape(radius: 15, corners: [.topLeft, .topRight]))
            .shadow(color: .bottomSheetShadowColor, radius: 20)
            .offset(y: dragOffset)
            .gesture(dragGesture)
            .transition(.move(edge: .bottom))
            .animation(.linear, value: isPresented)
        }
        .onAppear {
            animateSheetAppearance()
        }
    }
    
    private var topLineView: some View {
        LineView(width: 80, height: 5)
            .padding(.top, 10)
            .padding(.bottom, 5)
    }
    
    private var bottomLineView: some View {
        LineView(width: UIScreen.main.bounds.width, height: 1)
            .padding(.bottom, 10)
    }
    
    private var titleView: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.bottomSheetTitleColor)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
    }
    
    private var backgroundView: some View {
        ZStack {
            if backgroundBlur {
                Color.clear.background(BottomSheetBlurView(style: .light))
            } else if let bgImage = backgroundImage {
                bgImage.resizable().scaledToFill().clipped()
            } else {
                backgroundColor
            }
        }
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                updateDragOffset(value.translation.height)
            }
            .onEnded { value in
                handleDragEnd(value.translation.height)
            }
    }
    
    private func dismissSheet() {
        withAnimation(.linear(duration: 0.3)) {
            dragOffset = UIScreen.main.bounds.height
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isPresented = false
            }
        }
    }
    
    private func animateSheetAppearance() {
        dragOffset = height
        withAnimation(.linear(duration: 0.3)) {
            dragOffset = 0
        }
    }
    
    private func updateDragOffset(_ translationHeight: CGFloat) {
        lastDragPositions.append(translationHeight)
        if lastDragPositions.count > 10 {
            lastDragPositions.removeFirst()
        }
        if translationHeight > 0 {
            dragOffset = translationHeight
        }
    }
    
    private func handleDragEnd(_ translationHeight: CGFloat) {
        if let last = lastDragPositions.last, let first = lastDragPositions.first {
            let dragDifference = last - first
            if dragDifference > 5 && translationHeight > 5 {
                dismissSheet()
            } else {
                withAnimation(.linear(duration: 0.3)) {
                    dragOffset = 0
                }
            }
        }
        lastDragPositions.removeAll()
    }
}

//MARK: VIEW EXTENSION
extension View {
    func bottomSheet<SheetContent: View>(
        isPresented: Binding<Bool>,
        height: CGFloat = 0,
        title: String = "",
        backgroundColor: Color = Color.mainColor,
        backgroundImage: Image? = nil,
        backgroundBlur: Bool = false,
        showLines: Bool = true,
        @ViewBuilder sheetContent: @escaping () -> SheetContent
    ) -> some View {
        self.modifier(BottomSheetModifier(
            isPresented: isPresented,
            height: height,
            title: title,
            backgroundColor: backgroundColor,
            backgroundImage: backgroundImage,
            backgroundBlur: backgroundBlur,
            showLines: showLines,
            sheetContent: sheetContent
        ))
    }
}
