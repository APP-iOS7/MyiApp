//
//  NewBabyProfileView.swift
//  MyiApp
//
//  Created by Yung Hak Lee on 5/21/25.
//

import SwiftUI
import PhotosUI

struct NewBabyProfileView: View {
    @StateObject private var viewModel: BabyProfileViewModel
    @State private var showPhotoActionSheet = false
    @State private var showPhotoPicker = false
    @State private var uploadError: String?
    @State private var isEditing = false
    @State private var showAlert = false
    @State private var originalBaby: Baby
    @Environment(\.dismiss) private var dismiss
    
    let baby: Baby
    
    init(baby: Baby) {
        self.baby = baby
        self._viewModel = StateObject(wrappedValue: BabyProfileViewModel(baby: baby))
        self._originalBaby = State(initialValue: baby)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                // 아기 사진
                if let image = viewModel.babyImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .frame(maxWidth: .infinity, alignment: .center)
                        .onTapGesture {
                            if isEditing {
                                showPhotoActionSheet = true
                            }
                        }
                } else {
                    Image("sharkToddler")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .onTapGesture {
                            if isEditing {
                                showPhotoActionSheet = true
                            }
                        }
                }
                
                // 아기 정보
                VStack(alignment: .leading, spacing: 0) {
                    Text("이름")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary.opacity(0.8))
                        .padding()
                        .padding(.top, 10)
                    
                    Spacer()
                    
                    HStack {
                        if isEditing {
                            TextField("이름", text: $viewModel.baby.name)
                                .multilineTextAlignment(.leading)
                                .foregroundColor(.primary.opacity(0.6))
                                .font(.system(size: 17))
                                .background(Color(UIColor.tertiarySystemBackground))
                                .cornerRadius(5)
                        } else {
                            Text("\(viewModel.baby.name)")
                                .foregroundColor(.primary.opacity(0.6))
                                .font(.system(size: 17))
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.primary.opacity(0.6))
                            .padding(.trailing, 18)
                    }
                    .padding()
                    .padding(.bottom, 10)
                }
                .background(Color(UIColor.tertiarySystemBackground))
                .cornerRadius(10)
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 0) {
                        Text("생년월일")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary.opacity(0.8))
                            .padding()
                            .padding(.top, 10)
                        
                        HStack {
                            if isEditing {
                                DatePicker("", selection: $viewModel.baby.birthDate, displayedComponents: [.date])
                                    .labelsHidden()
                            } else {
                                Text("\(viewModel.formattedDate(viewModel.baby.birthDate))")
                                    .foregroundColor(.primary.opacity(0.6))
                                    .font(.system(size: 17))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.primary.opacity(0.8))
                                .padding(.trailing, 18)
                        }
                        .padding()
                        .padding(.top, 5)
                        .padding(.bottom, 5)
                        
                        let components = Calendar.current.dateComponents([.hour, .minute], from: viewModel.baby.birthDate)
                        if components.hour != 0 || components.minute != 0 {
                        }
                        
                        HStack {
                            if isEditing {
                                DatePicker("", selection: $viewModel.baby.birthDate, displayedComponents: [.hourAndMinute])
                                    .labelsHidden()
                            } else {
                                Text(viewModel.formattedTime(viewModel.baby.birthDate))
                                    .foregroundColor(.primary.opacity(0.6))
                                    .font(.system(size: 17))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.primary.opacity(0.8))
                                .padding(.trailing, 18)
                        }
                        .padding()
                        .padding(.bottom, 10)
                }
                .background(Color(UIColor.tertiarySystemBackground))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // 성별
                VStack(alignment: .leading, spacing: 0) {
                    Text("성별")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary.opacity(0.8))
                        .padding()
                        .padding(.top, 10)
                    
                    HStack {
                        if isEditing {
                            Picker("", selection: $viewModel.baby.gender) {
                                Text("남").tag(Gender.male)
                                Text("여").tag(Gender.female)
                            }
                            .multilineTextAlignment(.trailing)
                            .pickerStyle(MenuPickerStyle())
                            .foregroundColor(.primary.opacity(0.6))
                        } else {
                            Text("\(viewModel.baby.gender == .male ? "남" : "여")")
                                .foregroundColor(.primary.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.primary.opacity(0.8))
                            .padding(.trailing, 18)
                    }
                    .padding()
                    .padding(.bottom, 10)
                }
                .background(Color(UIColor.tertiarySystemBackground))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // 키/몸무게
                VStack(alignment: .leading, spacing: 0) {
                        Text("키 / 몸무게")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary.opacity(0.8))
                            .padding()
                            .padding(.top, 10)
                    HStack {
                        if isEditing {
                            TextField("키", value: $viewModel.baby.height, formatter: NumberFormatter())
                                .multilineTextAlignment(.leading)
                                .keyboardType(.decimalPad)
                                .foregroundColor(.primary.opacity(0.6))
                                .font(.system(size: 17))
                                .background(Color(UIColor.tertiarySystemBackground))
                                .cornerRadius(5)
                        } else {
                            Text("\(String(format: "%.1f", viewModel.baby.height))")
                                .foregroundColor(.primary.opacity(0.6))
                                .font(.system(size: 17))
                        }
                        
                        Text("cm")
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.primary.opacity(0.8))
                            .padding(.trailing, 18)
                    }
                    .padding()
                    .padding(.top, 5)
                    .padding(.bottom, 5)
                    
                    HStack {
                        if isEditing {
                            TextField("몸무게", value: $viewModel.baby.weight, formatter: NumberFormatter())
                                .multilineTextAlignment(.leading)
                                .keyboardType(.decimalPad)
                                .foregroundColor(.primary.opacity(0.6))
                                .font(.system(size: 17))
                                .background(Color(UIColor.tertiarySystemBackground))
                                .cornerRadius(5)
                        } else {
                            Text("\(String(format: "%.1f", viewModel.baby.weight))")
                                .foregroundColor(.primary.opacity(0.6))
                                .font(.system(size: 17))
                        }
                        
                        Text("kg")
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.primary.opacity(0.8))
                            .padding(.trailing, 18)
                    }
                    .padding()
                    .padding(.bottom, 10)
                }
                .background(Color(UIColor.tertiarySystemBackground))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // 혈액형
                VStack(alignment: .leading, spacing: 0) {
                    Text("혈액형")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary.opacity(0.8))
                        .padding()
                        .padding(.top, 10)
                    HStack {
                        if isEditing {
                            Picker("", selection: $viewModel.baby.bloodType) {
                                Text(BloodType.A.rawValue).tag(BloodType.A)
                                Text(BloodType.B.rawValue).tag(BloodType.B)
                                Text(BloodType.AB.rawValue).tag(BloodType.AB)
                                Text(BloodType.O.rawValue).tag(BloodType.O)
                            }
                            .pickerStyle(MenuPickerStyle())
                        } else {
                            Text("\(viewModel.baby.bloodType.rawValue)")
                                .foregroundColor(.primary.opacity(0.6))
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.primary.opacity(0.8))
                            .padding(.trailing, 18)
                    }
                    .padding()
                    .padding(.bottom, 10)
                }
                .background(Color(UIColor.tertiarySystemBackground))
                .cornerRadius(10)
                .padding(.horizontal)
            }
        }
        .background(Color("customBackgroundColor"))
        .navigationTitle("\(viewModel.baby.name)님의 정보")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(isEditing)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if isEditing {
                    Button("취소") {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.resetChanges()
                            isEditing = false
                        }
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "완료" : "편집") {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if isEditing {
                            Task {
                                await viewModel.saveBabyImage()
                                await viewModel.saveProfileEdits()
                                showAlert = true
                            }
                        } else {
                            isEditing = false
                        }
                        isEditing.toggle()
                    }
                }
            }
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(viewModel.isProfileSaved ? "저장 완료" : "오류"),
                message: Text(viewModel.isProfileSaved ? "프로필이 성공적으로 저장되었습니다." : viewModel.errorMessage ?? "알 수 없는 오류가 발생했습니다."),
                dismissButton: .default(Text("확인"))
            )
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
                }
            }
            Button("닫기", role: .cancel) {
                showPhotoActionSheet = false
            }
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $viewModel.selectedImage, matching: .images)
    }
}

#Preview {
    let dummyBaby = Baby(
        name: "후추",
        birthDate: Date(),
        gender: .female,
        height: 85.5,
        weight: 12.3,
        bloodType: .A,
    )
    NavigationView {
        NewBabyProfileView(baby: dummyBaby)
    }
}
