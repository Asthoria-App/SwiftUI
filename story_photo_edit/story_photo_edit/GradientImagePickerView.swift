//
//  GradientImagePickerView.swift
//  story_photo_edit
//
//  Created by Aysema Çam on 29.08.2024.
//

import SwiftUI

struct GradientImagePickerView: View {
    let gradients: [LinearGradient]
    @Binding var selectedGradient: LinearGradient?
    @Binding var selectedImage: UIImage?
    @Binding var showBackgroundImagePicker: Bool
    
    @State private var showPhotoPicker = false
    
    var body: some View {
        VStack {
            Text("Choose a Background")
                .font(.headline)
                .padding()
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(gradients.indices, id: \.self) { index in
                        Button(action: {
                            selectedGradient = gradients[index]
                            selectedImage = nil
                            showBackgroundImagePicker = false
                        }) {
                            gradients[index]
                                .frame(width: 100, height: 100)
                                .cornerRadius(12)
                                .shadow(radius: 5)
                        }
                    }
                }
                .padding()
            }
            
            Button("Choose from Gallery") {
                showPhotoPicker = true
            }
            .padding()
            .sheet(isPresented: $showPhotoPicker) {
                ImagePicker(selectedImage: $selectedImage)
                    .onDisappear {
                        showBackgroundImagePicker = false
                    }
            }
            
            Button("Cancel") {
                showBackgroundImagePicker = false
            }
            .padding()
        }
    }
}
