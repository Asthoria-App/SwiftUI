//
//  TagOverlayView.swift
//  story_photo_edit
//
//  Created by Aysema Çam on 10.09.2024.
//

import SwiftUI

struct User: Identifiable {
    let id: UUID = UUID()
    let username: String
    let profileImage: UIImage
}

struct TagOverlayView: View {
    @Binding var showTagOverlay: Bool
    @Binding var tagText: String
    @Binding var draggableTags: [DraggableTag]
    @Binding var globalIndex: CGFloat
    
    @State private var textHeight: CGFloat = 30
    @State private var textWidth: CGFloat = 30
    @State private var selectedFont: CustomFont = .roboto
    @State private var fontSize: CGFloat = 24
    @State private var textColor: Color = .black
    @State private var backgroundColor: Color = .white
    @State private var filteredUsers: [User] = []
    @State private var searchTask: DispatchWorkItem?
    
    let allUsers: [User]
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    dismissKeyboard()
                    appendTagAndCloseOverlay()
                }
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        dismissKeyboard()
                        appendTagAndCloseOverlay()
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
                
                DynamicHeightTextView(
                    text: Binding(
                        get: {
                            return tagText.count > 1 ? tagText : "@"
                        },
                        set: { newValue in
                            if newValue.hasPrefix("@") {
                                tagText = newValue
                            } else {
                                tagText = "@" + newValue
                            }
                            startSearch(with: newValue)
                        }
                    ),
                    minHeight: 30,
                    maxHeight: 150,
                    textHeight: $textHeight,
                    textColor: $textColor,
                    backgroundOpacity: .constant(0.7),
                    backgroundColor: $backgroundColor,
                    selectedFont: $selectedFont,
                    textWidth: $textWidth,
                    fontSize: $fontSize,
                    lastScale: .constant(1.0)
                )
                .frame(width: textWidth, height: textHeight)
                .padding(8)
                .background(Color.clear)
                .cornerRadius(5)
                .onAppear {
                    tagText = "@"
                    filteredUsers = allUsers
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        focusTextView()
                    }
                }
                
                if !filteredUsers.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(filteredUsers) { user in
                                VStack(spacing: 5) {
                                    Image(uiImage: user.profileImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                    
                                    Text(user.username)
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                                .frame(width: 70)
                                .onTapGesture {
                                    tagText = "@\(user.username)"
                                    appendTagAndCloseOverlay()
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 10)
                    }
                    .padding(.bottom, 10)
                    .padding(.leading, 10)
                }
                
            }
        }
        
    }
    
    private func startSearch(with newValue: String) {
        searchTask?.cancel()
        
        let task = DispatchWorkItem {
            let searchText = String(newValue.dropFirst())
            if searchText.isEmpty {
                self.filteredUsers = allUsers
            } else {
                self.filteredUsers = self.allUsers.filter { $0.username.lowercased().contains(searchText.lowercased()) }
            }
        }
        
        searchTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: task)
    }
    
    private func appendTagAndCloseOverlay() {
        if tagText.count > 1 {
            let newDraggableTag = DraggableTag(
                text: tagText,
                position: .zero,
                scale: 1.0,
                angle: .zero,
                zIndex: globalIndex,
                originalText: tagText,
                image: UIImage()
            )
            globalIndex += 1
            draggableTags.append(newDraggableTag)
        }
        
        showTagOverlay = false
        tagText = "@"
    }
}
