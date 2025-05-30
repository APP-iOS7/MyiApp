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
    @State private var showDeleteConfirmation = false
    @State private var isLoading: Bool = false
    @State private var showingBabyDeleteAlert = false
    @State private var showingErrorAlert = false
    @State private var errorMessage: String?
    @State private var babyToDelete: Baby?
    @Environment(\.dismiss) private var dismiss
    
    let baby: Baby
    
    init(baby: Baby) {
        self.baby = baby
        self._viewModel = StateObject(wrappedValue: BabyProfileViewModel(baby: baby))
    }
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                VStack(spacing: 20) {
                    // 아기 사진
                    ZStack(alignment: .bottom) {
                        VStack {
                            KFImage(URL(string: viewModel.baby.photoURL ?? ""))
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
                    .padding()
                    
                    VStack {
                        // 아기 정보
                        NavigationLink(destination: BabyNameEditView(viewModel: viewModel)) {
                            HStack {
                                Text("이름 / 태명")
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
                        
                        HStack {
                            Text("아이 정보 공유 코드")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .lineLimit(2)
                                .minimumScaleFactor(0.8)
                                .foregroundColor(.primary.opacity(0.8))
                            
                            Spacer()
                            
                            Image(systemName: "doc.on.doc")
                                .foregroundColor(.primary.opacity(0.6))
                                .font(.system(size: 12))
                        }
                        .padding()
                    }
                }
                .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(UIColor.tertiarySystemBackground))
                    )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .navigationTitle("\(viewModel.baby.name)님의 정보")
                .navigationBarTitleDisplayMode(.inline)
                .task {
                    await viewModel.loadBabyProfileImage()
                }
                .onChange(of: viewModel.selectedImage) {
                    Task {
                        isLoading = true
                        await viewModel.loadSelectedBabyImage()
                        await viewModel.saveBabyImage()
                        isLoading = false
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
                            isLoading = true
                            viewModel.babyImage = nil
                            viewModel.selectedImage = nil
                            await viewModel.saveBabyImage()
                            errorMessage = "프로필 사진이 삭제되었습니다."
                            showingErrorAlert = true
                            isLoading = false
                        }
                    }
                    Button("취소", role: .cancel) {}
                }
                .alert("아이 정보 삭제", isPresented: $showingBabyDeleteAlert) {
                    Button("삭제", role: .destructive) {
                        if let babyToDelete = babyToDelete {
                            Task {
                                isLoading = true
                                try await CaregiverManager.shared.deleteBaby(babyToDelete)
                                print("아이 삭제 성공")
                                await MainActor.run { dismiss() }
                                isLoading = false
                                self.babyToDelete = nil
                            }
                        }
                    }
                    Button("취소", role: .cancel) {
                        babyToDelete = nil
                    }
                } message: {
                    Text("'\(babyToDelete?.name ?? "")' 아기 정보를 삭제하시겠습니까?")
                }
                .alert("오류", isPresented: $showingErrorAlert) {
                    Button("확인", role: .cancel) {}
                } message: {
                    Text(errorMessage ?? "알 수 없는 오류가 발생했습니다.")
                }
                .photosPicker(isPresented: $showPhotoPicker, selection: $viewModel.selectedImage, matching: .images)
                
                if isLoading {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                        .opacity(isLoading ? 1 : 0)
                        .animation(.easeInOut(duration: 0.3), value: isLoading)
                }
            }
            
            Spacer()
            
            Button(action: {
                babyToDelete = baby
                showingBabyDeleteAlert = true
            }) {
                Text("아이 정보 삭제")
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding()
                    .underline()
            }
        }
        .padding(.horizontal)
        .background(Color("customBackgroundColor"))
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
