
//
//  BottomSheet.swift
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
    let sheetContent: () -> SheetContent  // sheetContent bir closure olarak tanımlandı
    let showLines: Bool
    let canCloseAtScrollTop: Bool

    @State private var dragOffset: CGFloat = 0
    @State private var lastDragPositions: [CGFloat] = []
    @State private var isAtTop: Bool = true  // Scroll pozisyonunu kontrol edeceğimiz flag

    init(isPresented: Binding<Bool>, height: CGFloat, title: String, backgroundColor: Color, backgroundImage: Image? = nil, backgroundBlur: Bool = false, showLines: Bool = true, canCloseAtScrollTop: Bool = false, @ViewBuilder sheetContent: @escaping () -> SheetContent) {
        self._isPresented = isPresented
        self.height = height
        self.title = title
        self.backgroundColor = backgroundColor
        self.backgroundImage = backgroundImage
        self.backgroundBlur = backgroundBlur
        self.showLines = showLines
        self.canCloseAtScrollTop = canCloseAtScrollTop
        self.sheetContent = sheetContent
    }

    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isPresented {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.linear(duration: 0.3)) {
                            dragOffset = UIScreen.main.bounds.height
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                isPresented = false
                            }
                        }
                    }

                VStack {
                    Spacer()

                    VStack(spacing: 0) {
                        if showLines {
                            LineView(width: 80, height: 5)
                                .padding(.top, 10)
                                .padding(.bottom, 5)
                        }

                        if title != "" {
                            Text(title)
                                .font(.headline)
                                .foregroundColor(.bottomSheetTitleColor)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        }

                        if showLines {
                            LineView(width: UIScreen.main.bounds.width, height: 1)
                                .padding(.bottom, 10)
                        }

                        sheetContent()
                            .background(
                                GeometryReader { proxy in
                                    Color.clear
                                        .preference(key: ScrollViewOffsetKey.self, value: proxy.frame(in: .named("scroll")).origin.y)
                                }
                            )
                            .onPreferenceChange(ScrollViewOffsetKey.self) { value in
                                // ScrollView en üstte mi kontrol ediyoruz
                                if value == 0 {
                                    isAtTop = true
                                    print("isAtTop is now true")
                                } else {
                                    isAtTop = false
                                    print("isAtTop is now false")
                                }
                            }
                    }
                    .frame(width: UIScreen.main.bounds.width, height: height, alignment: .top)
                    .background(
                        ZStack {
                            if backgroundBlur {
                                Color.clear.background(BlurView(style: .light))
                            } else if let bgImage = backgroundImage {
                                bgImage
                                    .resizable()
                                    .scaledToFill()
                                    .clipped()
                            } else {
                                backgroundColor
                            }
                        }
                    )
                    .clipShape(RoundedCornerShape(radius: 15, corners: [.topLeft, .topRight]))
                    .shadow(color: .bottomSheetShadowColor, radius: 20)
                    .offset(y: dragOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                lastDragPositions.append(value.translation.height)

                                if lastDragPositions.count > 10 {
                                    lastDragPositions.removeFirst()
                                }

                                if value.translation.height > 0 {
                                    dragOffset = value.translation.height
                                }
                            }
                            .onEnded { value in
                                if let last = lastDragPositions.last, let first = lastDragPositions.first {
                                    let dragDifference = last - first

                                    // DragGesture sona erdiğinde kapanma kontrolü
                                    if dragDifference > 5 && value.translation.height > 5 {
                                        withAnimation(.linear(duration: 0.3)) {
                                            dragOffset = UIScreen.main.bounds.height
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                isPresented = false
                                            }
                                        }
                                    } else {
                                        withAnimation(.linear(duration: 0.3)) {
                                            dragOffset = 0
                                        }
                                    }
                                }

                                lastDragPositions.removeAll()
                            }
                    )
                    .transition(.move(edge: .bottom))
                    .animation(.linear, value: isPresented)
                }
                .onAppear {
            
                    dragOffset = height
                    withAnimation(.linear(duration: 0.3)) {
                        dragOffset = 0
                    }
                }
                
                

            
            }
        }
    }
}

struct ScrollViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat

    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}



struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
        return view
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

extension View {
    func bottomSheet<SheetContent: View>(
        isPresented: Binding<Bool>,
        height: CGFloat = 0,
        title: String = "",
        backgroundColor: Color = Color.mainColor,
        backgroundImage: Image? = nil,
        backgroundBlur: Bool = false,
        showLines: Bool = true,
        canCloseAtScrollTop: Bool = false,  // Yeni flag burada
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
            canCloseAtScrollTop: canCloseAtScrollTop,  // Ve burada
            sheetContent: sheetContent
        ))
    }
}


struct RoundedCornerShape: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
