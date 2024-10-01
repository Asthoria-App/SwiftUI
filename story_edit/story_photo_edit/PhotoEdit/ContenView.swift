//
//  ContenView.swift
//  story_photo_edit
//
//  Created by Aysema Çam on 1.10.2024.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedBackgroundType: BackgroundType = .photo
    @State private var backgroundImage: UIImage? = UIImage(named: "image")
    @State private var inputVideoURL: URL? = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")
    @State private var showStoryEditView: Bool = false
    

    var body: some View {
        VStack(spacing: 20) {
            Button("Video") {
                selectedBackgroundType = .video
                showStoryEditView = true
            }
          
            
            Button("Photo") {
                selectedBackgroundType = .photo
                showStoryEditView = true
            }
        }
        
        .fullScreenCover(isPresented: $showStoryEditView) {
                 StoryEditView(
                     backgroundType: $selectedBackgroundType,
                     backgroundImage: $backgroundImage,
                     inputVideoURL: $inputVideoURL
                 )
             }
    }
}
