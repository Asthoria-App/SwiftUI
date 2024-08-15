import SwiftUI
import AVKit
import VideoProcessorSDK // Assuming this is your custom SDK

struct ContentView: View {
    @StateObject private var videoProcessor = VideoProcessor(videoURL: Bundle.main.url(forResource: "1", withExtension: "mp4")!)
    @State private var finalVideoURL: URL?
    @State private var videoSpeed: Float = 1.0
    @State private var makeBoomerang: Bool = true
    @State private var isProcessing: Bool = false

    var body: some View {
        VStack {
            // Video Player
            if isProcessing {
                ProgressView("Processing video...")
                    .progressViewStyle(CircularProgressViewStyle())
            } else if let url = finalVideoURL {
                VideoPlayer(player: AVPlayer(url: url))
                    .frame(height: 300)
            } else {
                Text("Ready to process video")
            }

            // Filter Buttons
            ScrollView(.horizontal) {
                HStack {
                    Button("Sepia") {
                        applyFilter(.sepia)
                    }
                    Button("Noir") {
                        applyFilter(.noir)
                    }
                    Button("Invert") {
                        applyFilter(.invert)
                    }
                    Button("Posterize") {
                        applyFilter(.posterize)
                    }
                    Button("Vignette") {
                        applyFilter(.vignette)
                    }
                }
                .padding()
            }

            // Speed and Boomerang Control Buttons
            HStack {
                Button("Speed x2") {
                    videoSpeed = 2.0
                    processVideo()
                }
                Button("Speed x4") {
                    videoSpeed = 4.0
                    processVideo()
                }
                Button("Boomerang On") {
                    makeBoomerang = true
                    processVideo()
                }
                Button("Boomerang Off") {
                    makeBoomerang = false
                    processVideo()
                }
            }
            .padding()
        }
    }

    // Apply selected filter and process video
    private func applyFilter(_ filter: VideoFilter) {
        videoProcessor.setFilter(filter)
        processVideo()
    }

    // Video processing function
    private func processVideo() {
        isProcessing = true
        videoProcessor.setVideo(speed: videoSpeed)
        videoProcessor.processVideo(applyBoomerang: makeBoomerang) { url in
            DispatchQueue.main.async {
                self.finalVideoURL = url
                self.isProcessing = false
            }
        }
    }
}
