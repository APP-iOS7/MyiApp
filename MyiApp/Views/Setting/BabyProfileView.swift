//
//  BabyProfileView.swift
//  MyiApp
//
//  Created by Yung Hak Lee on 5/13/25.
//

//
//  BabyProfileView.swift
//  MyiApp
//
//  Created by [Your Name] on 5/20/25.
//

import SwiftUI
import PhotosUI

struct BabyProfileView: View {
    @StateObject private var viewModel: BabyProfileViewModel
    @State private var showPhotoActionSheet = false
    @State private var showPhotoPicker = false
    @State private var uploadError: String?
    let baby: Baby
    
    init(baby: Baby) {
            self.baby = baby
            self._viewModel = StateObject(wrappedValue: BabyProfileViewModel(baby: baby))
        }
    
    var body: some View {
        VStack {
            VStack(spacing: 40) {
                // 아기 사진
                if let image = viewModel.babyImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .frame(maxWidth: .infinity, alignment: .center)
                        .onTapGesture {
                            showPhotoActionSheet = true
                        }
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .onTapGesture {
                            showPhotoActionSheet = true
                        }
                }
                
                // 아기 정보
                    HStack {
                        Text("이름")
                            .fontWeight(.bold)
                            .foregroundColor(.primary.opacity(0.8))
                            .padding(.leading, 5)
                        
                        Spacer()
                        
                        Text("\(baby.name)")
                            .foregroundColor(.primary.opacity(0.6))
                            .padding(.trailing, 5)
                    }
                    HStack {
                        Text("생년월일")
                            .fontWeight(.bold)
                            .foregroundColor(.primary.opacity(0.8))
                            .padding(.leading, 5)
                        Spacer()
                        Text("\(viewModel.formattedDate(baby.birthDate))")
                            .foregroundColor(.primary.opacity(0.6))
                            .padding(.trailing, 5)
                    }
                    let components = Calendar.current.dateComponents([.hour, .minute], from: baby.birthDate)
                    if components.hour != 0 || components.minute != 0 {
                        HStack {
                            Text("출생 시간")
                                .fontWeight(.bold)
                                .foregroundColor(.primary.opacity(0.8))
                                .padding(.leading, 5)
                            Spacer()
                            Text(viewModel.formattedTime(baby.birthDate))
                                .foregroundColor(.primary.opacity(0.6))
                                .padding(.trailing, 5)
                        }
                    }
                    HStack {
                        Text("성별")
                            .fontWeight(.bold)
                            .foregroundColor(.primary.opacity(0.8))
                            .padding(.leading, 5)
                        Spacer()
                        Text("\(baby.gender == .male ? "남" : "여")")
                            .foregroundColor(.primary.opacity(0.8))
                            .padding(.trailing, 5)
                    }
                    HStack {
                        Text("키")
                            .fontWeight(.bold)
                            .foregroundColor(.primary.opacity(0.8))
                            .padding(.leading, 5)
                        Spacer()
                        Text("\(String(format: "%.1f", baby.height)) cm")
                            .foregroundColor(.primary.opacity(0.6))
                            .padding(.trailing, 5)
                    }
                    HStack {
                        Text("몸무게")
                            .fontWeight(.bold)
                            .foregroundColor(.primary.opacity(0.8))
                            .padding(.leading, 5)
                        Spacer()
                        Text("\(String(format: "%.1f", baby.weight)) kg")
                            .foregroundColor(.primary.opacity(0.6))
                            .padding(.trailing, 5)
                    }
                    HStack {
                        Text("혈액형")
                            .fontWeight(.bold)
                            .foregroundColor(.primary.opacity(0.8))
                            .padding(.leading, 5)
                        Spacer()
                        Text("\(baby.bloodType.rawValue)")
                            .foregroundColor(.primary.opacity(0.6))
                            .padding(.trailing, 5)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 30)
                .background(Color(UIColor.tertiarySystemBackground))
                
                Spacer()
            
        }
        .background(Color("customBackgroundColor"))
        .navigationTitle("\(baby.name)님의 정보")
        .navigationBarTitleDisplayMode(.inline)
        .padding(.top, 20)
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .task {
            await viewModel.loadBabyProfileImage()
        }
        .onChange(of: viewModel.selectedImage) {
            Task {
                await viewModel.loadSelectedBabyImage()
            }
        }
        .confirmationDialog("프로필 사진 변경", isPresented: $showPhotoActionSheet, titleVisibility: .visible) {
            Button("앨범에서 선택") {
                showPhotoPicker = true
            }
            Button("프로필 사진 삭제", role: .destructive) {
                Task {
                    viewModel.babyImage = nil
                    viewModel.selectedImage = nil
                    await viewModel.saveBabyImage()
                }
            }
            Button("닫기", role: .cancel) {
                showPhotoActionSheet = false
            }
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $viewModel.selectedImage, matching: .images)
    }
}

struct BabyProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleBaby = Baby(
            name: "후추",
            birthDate: Date(),
            gender: .female,
            height: 50.5,
            weight: 3.2,
            bloodType: .A
        )
        BabyProfileView(baby: sampleBaby)
    }
}
