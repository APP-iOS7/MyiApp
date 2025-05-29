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
            ZStack(alignment: .topTrailing) {
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
                    Text("\(currentIndex + 1)/\(imageURLs.count)")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.black.opacity(0.6)))
                        .padding(.trailing, 12)
                        .padding(.top, 8)
                }
            }
            
            if imageURLs.count > 1 {
                HStack(spacing: 6) {
                    ForEach(0..<imageURLs.count, id: \.self) { index in
                        Circle()
                            .fill(currentIndex == index ? Color("sharkPrimaryColor") : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut(duration: 0.2), value: currentIndex)
                    }
                }
                .padding(.top, 12)
                .padding(.bottom, 8)
            }
        }
    }
}

struct CustomAsyncImageView: View {
    let imageUrlString: String
    let localImage: UIImage?
    
    @State private var image: UIImage? = nil
    @State private var isLoading = true
    
    init(imageUrlString: String, localImage: UIImage? = nil) {
        self.imageUrlString = imageUrlString
        self.localImage = localImage
    }
    
    var body: some View {
        ZStack {
            if let localImage = localImage {
                Image(uiImage: localImage)
                    .resizable()
                    .scaledToFill()
            } else if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color("sharkPrimaryColor")))
                    .scaleEffect(1.5)
            } else {
                Image(systemName: "photo")
                    .foregroundColor(.gray)
                    .font(.largeTitle)
            }
        }
        .onAppear {
            if localImage == nil {
                loadImage()
            } else {
                isLoading = false
            }
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
