//
//  UserProfileViewModel.swift
//  MyiApp
//
//  Created by Yung Hak Lee on 5/13/25.
//

import SwiftUI
import PhotosUI

@MainActor
final class AccountSettingsViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var profileImage: UIImage?
    @Published var selectedPhoto: PhotosPickerItem?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isProfileSaved: Bool = false
    
    private let databaseService = DatabaseService.shared
    private let imageCache: NSCache<NSString, UIImage> = {
            let cache = NSCache<NSString, UIImage>()
            cache.totalCostLimit = 50 * 1024 * 1024
            return cache
        }()
    
    static let shared = AccountSettingsViewModel()
    private init() {}
    
    // 초기 프로필 데이터 로드
    func loadProfile() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            let (name, imageUrl) = try await databaseService.fetchUserProfile()
            self.name = name ?? ""
            self.profileImage = nil
            
            if let imageUrl = imageUrl, let url = URL(string: imageUrl) {
                if let cachedImage = imageCache.object(forKey: imageUrl as NSString) {
                    self.profileImage = cachedImage
                    return
                }
                
                let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid HTTP response"])
                }
                
                guard httpResponse.statusCode == 200 else {
                    throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP error: \(httpResponse.statusCode)"])
                }
                
                guard let image = UIImage(data: data) else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert data to image"])
                }
                
                self.imageCache.setObject(image, forKey: imageUrl as NSString)
                self.profileImage = image
            } else {
                self.profileImage = nil
            }
        } catch {
            self.errorMessage = "Failed to load profile: \(error.localizedDescription) (Code: \((error as NSError).code))"
            self.profileImage = nil
        }
    }
    
    // 프로필 사진 선택 시 처리
    func loadSelectedPhoto() async {
        guard let selectedPhoto = selectedPhoto else { return }
        do {
            if let data = try await selectedPhoto.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                self.profileImage = image
            } else {
                self.errorMessage = "Failed to load selected photo"
            }
        } catch {
            self.errorMessage = "Failed to load photo: \(error.localizedDescription)"
        }
    }
    
    // 프로필 저장
    func saveProfile() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            var imageUrl: String?
            if let profileImage = profileImage {
                imageUrl = try await databaseService.uploadProfileImage(profileImage)
            }
            try await databaseService.saveUserProfile(name: name, imageUrl: imageUrl)
            self.errorMessage = nil
            self.isProfileSaved = true
        } catch {
            self.errorMessage = "프로필 저장 실패: \(error.localizedDescription)"
            self.isProfileSaved = false
        }
    }
}
