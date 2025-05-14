//
//  ImageGallery.swift
//  MyiApp
//
//  Created by Saebyeok Jang on 5/14/25.
//

import SwiftUI

struct ImageGallery: View {
    let imageURLs: [String]
    @State private var currentIndex = 0
    
    var body: some View {
        VStack(spacing: 0) {
            if imageURLs.count > 1 {
                HStack {
                    Spacer()
                    Text("\(currentIndex + 1)/\(imageURLs.count)")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.black.opacity(0.6)))
                        .padding(.trailing, 12)
                        .padding(.top, 8)
                }
                .zIndex(1)
            }
            
            TabView(selection: $currentIndex) {
                ForEach(Array(imageURLs.enumerated()), id: \.element) { index, url in
                    CustomAsyncImageView(imageUrlString: url)
                        .scaledToFill()
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: UIScreen.main.bounds.width)
            .clipped()
            
            if imageURLs.count > 1 {
                HStack(spacing: 4) {
                    ForEach(0..<imageURLs.count, id: \.self) { index in
                        Circle()
                            .fill(currentIndex == index ? Color("sharkPrimaryColor") : Color.gray.opacity(0.3))
                            .frame(width: 6, height: 6)
                    }
                }
                .padding(.top, 8)
            }
        }
    }
}

struct CustomAsyncImageView: View {
    let imageUrlString: String
    @State private var image: UIImage? = nil
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else if isLoading {
                ProgressView()
            } else {
                Image(systemName: "photo")
                    .foregroundColor(.gray)
                    .font(.largeTitle)
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        guard let imageURL = URL(string: imageUrlString) else {
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: imageURL) { data, response, error in
            isLoading = false
            
            if let data = data, let downloadedImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = downloadedImage
                }
            }
        }.resume()
    }
}
