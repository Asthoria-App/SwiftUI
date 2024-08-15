//
//  DetailView.swift
//  Meditation_swiftUI
//
//  Created by Aysema Çam on 7.08.2024.
//
import SwiftUI

struct DetailView: View {
    var title: String
    var meditations: [Meditation]
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack(alignment: .topLeading) {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 12) {
                    ForEach(meditations) { meditation in
                        CollectionViewCell(meditation: meditation)
                            .frame(height: UIScreen.main.bounds.width / 2 * 1.3)
                    }
                }
                .padding(12)
                .padding(.top, 60)
            }
            .background(Color.black)
            
            VisualEffectBlur(blurStyle: .systemMaterialDark)
                .edgesIgnoringSafeArea(.top)
                .frame(height: 60)
                .overlay(
                    HStack {
                        Spacer()
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "chevron.left")
                            .opacity(0)
                    }
                    .padding()
                    , alignment: .bottom
                )

            Button(action: {
                print("detail back button tapped")
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
                    .padding()
                    .clipShape(Circle())
            }
            .padding(.leading, 16)
            .padding(.top, 16)
        }
        .background(Color.black)
        .navigationBarHidden(true)
    }
}

struct CollectionViewCell: View {
    var meditation: Meditation

    var body: some View {
        ZStack(alignment: .topLeading) {
            Image(meditation.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: UIScreen.main.bounds.width / 2 - 18, height: UIScreen.main.bounds.width / 2 * 1.3)
                .cornerRadius(12)
                .clipped()

            VStack {
                HStack {
                    Image(systemName: meditation.isPremium ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                    Text(meditation.title)
                        .foregroundColor(.white)
                        .bold()
                    Spacer()
                }
                .padding(10)
                .background(Color.black.opacity(0.6))
                .frame(maxWidth: .infinity)

                Spacer()

                HStack {
                    Spacer()
                    Text(meditation.description)
                        .foregroundColor(.white)
                        .bold()
                    Spacer()
                }
                .padding(10)
                .background(Color.black.opacity(0.3))
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.black)
        .cornerRadius(12)
    }
}

struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: blurStyle)
    }
}

//struct DetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailView(title: "Meditations", meditations: sampleMeditations)
//    }
//}

