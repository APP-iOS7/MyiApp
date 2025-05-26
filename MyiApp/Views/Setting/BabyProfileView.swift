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
import Kingfisher

struct BabyProfileView: View {
    @StateObject private var viewModel: BabyProfileViewModel
    @State private var showPhotoActionSheet = false
    @State private var showPhotoPicker = false
    @State private var uploadError: String?
    @State private var showAlert: Bool = false
    @State private var showDeleteConfirmation = false
    @State private var isUploading: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    let baby: Baby
    
    init(baby: Baby) {
        self.baby = baby
        self._viewModel = StateObject(wrappedValue: BabyProfileViewModel(baby: baby))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            VStack {
                // 아기 사진
                ZStack(alignment: .bottom) {
                    ZStack {
                        KFImage(URL(string: viewModel.baby.photoURL ?? ""))
                            .placeholder({
                                if isUploading {
                                    ProgressView()
                                }
                            })
                            .onFailureImage(viewModel.displaySharkImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(.circle)
                            .background(
                                Circle()
                                    .fill(Color.sharkPrimaryLight)
                                    .stroke(Color.sharksSadowTone, lineWidth: 2)
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.sharksSadowTone, lineWidth: 2)
                            )
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .onTapGesture {
                        showPhotoActionSheet = true
                    }
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.gray)
                        .background(Circle().fill(Color.white).frame(width: 24, height: 24))
                        .offset(x: 42, y: -10)
                        .onTapGesture {
                            showPhotoActionSheet = true
                        }
                }
            }
            .padding(.bottom, 20)
            // 아기 정보
            NavigationLink(destination: BabyNameEditView(viewModel: viewModel)) {
                HStack {
                    Text("이름")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary.opacity(0.8))
                    
                    Spacer()
                    
                    Text("\(viewModel.baby.name)")
                        .foregroundColor(.primary.opacity(0.6))
                    Image(systemName: "chevron.right")
                        .foregroundColor(.primary.opacity(0.6))
                        .font(.system(size: 12))
                }
                .padding()
            }
            NavigationLink(destination: BabyBirthDayEditView(viewModel: viewModel)) {
                HStack {
                    Text("출생일")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary.opacity(0.8))
                    
                    Spacer()
                    
                    Text("\(viewModel.formattedDate(viewModel.baby.birthDate))")
                        .foregroundColor(.primary.opacity(0.6))
                    Image(systemName: "chevron.right")
                        .foregroundColor(.primary.opacity(0.6))
                        .font(.system(size: 12))
                }
                .padding()
            }
            let components = Calendar.current.dateComponents([.hour, .minute], from: viewModel.baby.birthDate)
            if components.hour == 0 && components.minute == 0 {
                NavigationLink(destination: BabyBirthTimeEditView(viewModel: viewModel)) {
                    HStack {
                        Text("출생 시간")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary.opacity(0.8))
                        
                        Spacer()
                        
                        Text("없음")
                            .foregroundColor(.primary.opacity(0.6))
                        Image(systemName: "chevron.right")
                            .foregroundColor(.primary.opacity(0.6))
                            .font(.system(size: 12))
                    }
                    .padding()
                }
            } else {
                NavigationLink(destination: BabyBirthTimeEditView(viewModel: viewModel)) {
                    HStack {
                        Text("출생 시간")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary.opacity(0.8))
                        
                        Spacer()
                        
                        Text(viewModel.formattedTime(viewModel.baby.birthDate))
                            .foregroundColor(.primary.opacity(0.6))
                        Image(systemName: "chevron.right")
                            .foregroundColor(.primary.opacity(0.6))
                            .font(.system(size: 12))
                    }
                    .padding()
                }
            }
            NavigationLink(destination: BabyGenderEditView(viewModel: viewModel)) {
                HStack {
                    Text("성별")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary.opacity(0.8))
                    
                    Spacer()
                    
                    Text("\(viewModel.baby.gender == .male ? "남" : "여")")
                        .foregroundColor(.primary.opacity(0.6))
                    Image(systemName: "chevron.right")
                        .foregroundColor(.primary.opacity(0.6))
                        .font(.system(size: 12))
                }
                .padding()
            }
            NavigationLink(destination: BabyHeightEditView(viewModel: viewModel)) {
                HStack {
                    Text("키")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary.opacity(0.8))
                    
                    Spacer()
                    
                    Text(viewModel.formatNumber(viewModel.baby.height) + " cm")
                        .foregroundColor(.primary.opacity(0.6))
                    Image(systemName: "chevron.right")
                        .foregroundColor(.primary.opacity(0.6))
                        .font(.system(size: 12))
                }
                .padding()
            }
            NavigationLink(destination: BabyWeightEditView(viewModel: viewModel)) {
                HStack {
                    Text("몸무게")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary.opacity(0.8))
                    
                    Spacer()
                    
                    Text(viewModel.formatNumber(viewModel.baby.weight) + " kg")
                        .foregroundColor(.primary.opacity(0.6))
                    Image(systemName: "chevron.right")
                        .foregroundColor(.primary.opacity(0.6))
                        .font(.system(size: 12))
                }
                .padding()
            }
            NavigationLink(destination: BabyBloodEditView(viewModel: viewModel)) {
                HStack {
                    Text("혈액형")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary.opacity(0.8))
                    
                    Spacer()
                    
                    Text("\(viewModel.baby.bloodType.rawValue)")
                        .foregroundColor(.primary.opacity(0.6))
                    Image(systemName: "chevron.right")
                        .foregroundColor(.primary.opacity(0.6))
                        .font(.system(size: 12))
                }
                .padding()
            }
            
            Spacer()
        }
        .padding()
        .background(Color(UIColor.tertiarySystemBackground))
        .navigationTitle("\(viewModel.baby.name)님의 정보")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    if !isUploading {
                        dismiss()
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary.opacity(isUploading ? 0.3 : 0.8))
                }
                .disabled(isUploading)
            }
        }
        .task {
            await viewModel.loadBabyProfileImage()
        }
        .onChange(of: viewModel.selectedImage) {
            Task {
                isUploading = true
                await viewModel.loadSelectedBabyImage()
                await viewModel.saveBabyImage()
                isUploading = false
            }
        }
        .confirmationDialog("프로필 사진 변경", isPresented: $showPhotoActionSheet, titleVisibility: .visible) {
            Button("앨범에서 선택") {
                showPhotoPicker = true
            }
            Button("프로필 사진 삭제", role: .destructive) {
                showDeleteConfirmation = true
            }
            Button("닫기", role: .cancel) {}
        }
        .alert("프로필 사진을 삭제하시겠습니까?", isPresented: $showDeleteConfirmation) {
            Button("삭제", role: .destructive) {
                Task {
                    isUploading = true
                    viewModel.babyImage = nil
                    viewModel.selectedImage = nil
                    await viewModel.saveBabyImage()
                    uploadError = "프로필 사진이 삭제되었습니다."
                    showAlert = true
                    isUploading = false
                }
            }
            Button("취소", role: .cancel) {}
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
            height: 50,
            weight: 3.2,
            bloodType: .A
        )
        BabyProfileView(baby: sampleBaby)
    }
}
