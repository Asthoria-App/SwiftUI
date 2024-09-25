//
//  ContentView.swift
//  BottomSheetModifier
//
//  Created by Aysema Çam on 25.09.2024.
//

import SwiftUI
struct ContentView: View {
    @State private var showBottomSheetWithoutTitle = false
    @State private var showBottomSheetWithTitle = false
    @State private var showBottomSheetWithBackgroundColor = false
    @State private var showBottomSheetWithBackgroundImage = false
    @State private var showBottomSheetWithBackgroundBlur = false

    @State private var isAtTop = false  // ScrollView'dan gelen isAtTop flag
    @State private var canCloseAtScrollTop = false  // BottomSheet'teki flag

    var body: some View {
        VStack {
            Button("Show Bottom Sheet without title") {
                showBottomSheetWithoutTitle.toggle()
            }
            .padding()
            
            Button("Show Bottom Sheet with title") {
                showBottomSheetWithTitle.toggle()
            }
            .padding()
            
            Button("Show Bottom Sheet with background color") {
                showBottomSheetWithBackgroundColor.toggle()
            }
            .padding()
            
            Button("Show Bottom Sheet with background image") {
                showBottomSheetWithBackgroundImage.toggle()
            }
            .padding()
            
            Button("Show Bottom Sheet with background blur") {
                showBottomSheetWithBackgroundBlur.toggle()
            }
            .padding()
        }
        
        .background(
                   Image("3")
                       .resizable()
                       .scaledToFill()
                       .edgesIgnoringSafeArea(.all)
               )
        
        .bottomSheet(isPresented: $showBottomSheetWithoutTitle,
                     height: 300,
                     showLines: false,
                     canCloseAtScrollTop: canCloseAtScrollTop)
        {
            SimpleScrollView(isAtTop: $isAtTop, canCloseAtScrollTop: $canCloseAtScrollTop)
                .background(Color.red)
        }
        
        .bottomSheet(isPresented: $showBottomSheetWithTitle,
                     height: 500,
                     title: "Test Title",
                     canCloseAtScrollTop: canCloseAtScrollTop)
        {
            SimpleScrollView(isAtTop: $isAtTop, canCloseAtScrollTop: $canCloseAtScrollTop)
        }
        
        .bottomSheet(isPresented: $showBottomSheetWithBackgroundColor,
                     height: 600,
                     title: "Test Title",
                     backgroundColor: .purple,
                     canCloseAtScrollTop: canCloseAtScrollTop) {
            SimpleScrollView(isAtTop: $isAtTop, canCloseAtScrollTop: $canCloseAtScrollTop)
        }
        
        .bottomSheet(isPresented: $showBottomSheetWithBackgroundImage,
                     height: 600, title: "Test Title", backgroundColor: .purple,
                     backgroundImage: Image("wallpaper")) {
            Text("Test test test test")
                .foregroundColor(.blue)
            
            Image("1")
        }
        
        .bottomSheet(isPresented: $showBottomSheetWithBackgroundBlur,
                     height: 650,
                     title: "Test Title", backgroundBlur: true)
        {
            Text("Test test test test")
                .foregroundColor(.blue)
            
            Image("1")
        }
    }
}


struct SimpleScrollView: View {
    @Binding var isAtTop: Bool  // ScrollView'un en üstte olup olmadığını kontrol etmek için Binding
    @Binding var canCloseAtScrollTop: Bool  // canCloseAtScrollTop'u dışarıya bağlayacağız
    @State private var simpleScrollViewTop: CGFloat = 0  // SimpleScrollView top
    @State private var scrollViewTop: CGFloat = 0  // ScrollView top

    var body: some View {
        VStack(spacing: 0) {
            // SimpleScrollView'ın global frame'ini ölçüyoruz
            GeometryReader { simpleScrollViewGeo in
                Color.clear
                    .onChange(of: simpleScrollViewGeo.frame(in: .global).minY) { newValue in
                        simpleScrollViewTop = newValue
                        print("SimpleScrollView top:", simpleScrollViewTop)
                    }
            }
            .frame(height: 0)
            
            ScrollView {
                VStack(spacing: 0) {
                    // ScrollView'ın global frame'ini ölçüyoruz
                    GeometryReader { scrollViewGeo in
                        Color.clear
                            .onChange(of: scrollViewGeo.frame(in: .global).minY) { newValue in
                                scrollViewTop = newValue
                                print("ScrollView top:", scrollViewTop)
                            }
                    }
                    .frame(height: 0)
                    
                    ForEach(1..<21) { index in
                        Text("Item \(index)")
                            .padding()
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                .gesture(
                    DragGesture()
                        .onChanged { _ in
//                            print("Comparing tops - ScrollViewTop: \(scrollViewTop), SimpleScrollViewTop: \(simpleScrollViewTop)")
                            if scrollViewTop == simpleScrollViewTop {
                                isAtTop = true
                                canCloseAtScrollTop = true
                                print("canCloseAtScrollTop is now true")
                            } else {
                                isAtTop = false
                                canCloseAtScrollTop = false
                                print("canCloseAtScrollTop is now false")
                            }
                        }
                        .onEnded { _ in
                            print("Drag ended")
                        }
                )
            }
        }
    }
}
