//
//  PhotoPicker.swift
//  MyiApp
//
//  Created by Saebyeok Jang on 5/14/25.
//

import SwiftUI
import PhotosUI

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    var selectionLimit: Int
    var onCompletion: (() -> Void)?
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = selectionLimit
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker
        
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            let dispatchGroup = DispatchGroup()
            var newImages: [UIImage] = []
            
            for result in results {
                dispatchGroup.enter()
                
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
                        defer { dispatchGroup.leave() }
                        
                        guard let self = self, let image = object as? UIImage else { return }
                        newImages.append(image)
                    }
                } else {
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                self.parent.selectedImages.append(contentsOf: newImages)
                self.parent.onCompletion?()
            }
        }
    }
}

struct ImagePreviewGrid: View {
    @Binding var images: [UIImage]
    var onDelete: ((Int) -> Void)?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 10) {
                ForEach(0..<images.count, id: \.self) { index in
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: images[index])
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        
                        Button(action: {
                            onDelete?(index)
                        }) {
                            Circle()
                                .fill(Color.black.opacity(0.6))
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Image(systemName: "xmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                )
                        }
                        .padding(5)
                    }
                }
            }
            .padding(.horizontal)
        }
        .frame(height: images.isEmpty ? 0 : 120)
    }
}

struct URLImagePreviewGrid: View {
    var imageURLs: [String]
    var onDelete: ((Int) -> Void)?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 10) {
                ForEach(Array(imageURLs.enumerated()), id: \.element) { index, url in
                    ZStack(alignment: .topTrailing) {
                        CustomAsyncImageView(imageUrlString: url)
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        
                        if onDelete != nil {
                            Button(action: {
                                onDelete?(index)
                            }) {
                                Circle()
                                    .fill(Color.black.opacity(0.6))
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Image(systemName: "xmark")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.white)
                                    )
                            }
                            .padding(5)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .frame(height: imageURLs.isEmpty ? 0 : 120)
    }
}
