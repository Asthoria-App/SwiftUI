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
    @State private var canCloseAtScrollTop = false
    var body: some View {
        VStack {
            Button("Show Bottom Sheet Without Title") {
                showBottomSheetWithoutTitle.toggle()
            }
            .padding()
            
            Button("Show Bottom Sheet With Title") {
                showBottomSheetWithTitle.toggle()
            }
            .padding()
            
            Button("Show Bottom Sheet With Background Color\nNormal Modifier") {
                showBottomSheetWithBackgroundColor.toggle()
            }
            .padding()
            
            Button("Show Bottom Sheet With Background Image") {
                showBottomSheetWithBackgroundImage.toggle()
            }
            .padding()
            
            Button("Show Bottom Sheet With Background Blur") {
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
//        Usage with scrollView
        
        .bottomSheetWithScrollView(isPresented: $showBottomSheetWithoutTitle,
                                   height: 300,
                                   showLines: false,
                                   canCloseAtScrollTop: $canCloseAtScrollTop)
        {
            SimpleScrollView( canCloseAtScrollTop: $canCloseAtScrollTop)
                .background(Color.red)
        }
        
        .bottomSheetWithScrollView(isPresented: $showBottomSheetWithTitle,
                                   height: 500,
                                   title: "Test Title",
                                   canCloseAtScrollTop: $canCloseAtScrollTop)
        {
            SimpleScrollView(canCloseAtScrollTop: $canCloseAtScrollTop)
        }
        
        
//        Usage without scrollView
        .bottomSheet(isPresented: $showBottomSheetWithBackgroundColor,
                                   height: 600,
                                   title: "Test Title",
                                   backgroundColor: .purple
                                )
        {
            SimpleScrollView(canCloseAtScrollTop: $canCloseAtScrollTop)
        }
        
        .bottomSheet(isPresented: $showBottomSheetWithBackgroundImage,
                     height: 600, title: "Test Title", backgroundColor: .purple,
                     backgroundImage: Image("wallpaper"))
        {
            Text("Test descrittion for BottomSheet")
                .foregroundColor(.blue)
            Image("1")
        }
        
        .bottomSheet(isPresented: $showBottomSheetWithBackgroundBlur,
                     height: 650,
                     title: "Test Title", backgroundBlur: true)
        {
            Text("Test descrittion for BottomSheet")
                .foregroundColor(.blue)
            Image("1")
        }
    }
}


struct SimpleScrollView: View {
    @Binding var canCloseAtScrollTop: Bool
    @State private var simpleScrollViewTop: CGFloat = 0
    @State private var scrollViewTop: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { simpleScrollViewGeo in
                Color.clear
                    .onChange(of: simpleScrollViewGeo.frame(in: .global).minY) { newValue in
                        simpleScrollViewTop = newValue
                    }
            }
            .frame(height: 0)
            
            ScrollView {
                VStack(spacing: 0) {
                    GeometryReader { scrollViewGeo in
                        Color.clear
                            .onChange(of: scrollViewGeo.frame(in: .global).minY) { newValue in
                                scrollViewTop = newValue
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
                        .onChanged { value in
                            if value.translation.height > 0 {
                                if scrollViewTop == simpleScrollViewTop {
                                    canCloseAtScrollTop = true
                                } else {
                                    canCloseAtScrollTop = false
                                }
                            }
                        }
                )
            }
        }
    }
}
