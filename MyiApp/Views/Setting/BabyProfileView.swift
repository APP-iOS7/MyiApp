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
    @State private var isEditing = false
    @State private var showAlert = false
    
    let baby: Baby
    
    init(baby: Baby) {
        self.baby = baby
        self._viewModel = StateObject(wrappedValue: BabyProfileViewModel(baby: baby))
    }
    
    var body: some View {
        ScrollView {
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
                                if isEditing {
                                    showPhotoActionSheet = true
                                }
                            }
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundStyle(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .onTapGesture {
                                if isEditing {
                                    showPhotoActionSheet = true
                                }
                            }
                            .transition(.opacity)
                    }
                    
                    // 아기 정보
                    HStack {
                        Text("이름")
                            .fontWeight(.bold)
                            .foregroundColor(.primary.opacity(0.8))
                            .padding(.leading, 5)
                        
                        Spacer()
                        
                        if isEditing {
                            TextField("이름", text: $viewModel.baby.name)
                                .foregroundColor(.primary.opacity(0.6))
                                .font(.system(size: 17))
                                .multilineTextAlignment(.trailing)
                                .padding(.trailing, 5)
                                .background(Color(UIColor.tertiarySystemBackground))
                                .cornerRadius(5)
                        } else {
                            Text("\(viewModel.baby.name)")
                                .foregroundColor(.primary.opacity(0.6))
                                .font(.system(size: 17))
                                .padding(.trailing, 5)
                        }
                        Image(systemName: "chevron.right")
                            .foregroundColor(.primary.opacity(0.8))
                            .padding(.trailing, 18)
                    }
                    HStack {
                        Text("생년월일")
                            .fontWeight(.bold)
                            .foregroundColor(.primary.opacity(0.8))
                            .padding(.leading, 5)
                        Spacer()
                        if isEditing {
                            DatePicker("", selection: $viewModel.baby.birthDate, displayedComponents: [.date])
                                .labelsHidden()
                                .frame(width: 150, alignment: .trailing)
                                .padding(.trailing, 5)
                        } else {
                            Text("\(viewModel.formattedDate(viewModel.baby.birthDate))")
                                .foregroundColor(.primary.opacity(0.6))
                                .frame(width: 150, alignment: .trailing)
                                .padding(.trailing, 5)
                        }
                        Image(systemName: "chevron.right")
                            .foregroundColor(.primary.opacity(0.8))
                            .padding(.trailing, 18)
                    }
                    let components = Calendar.current.dateComponents([.hour, .minute], from: viewModel.baby.birthDate)
                    if components.hour != 0 || components.minute != 0 {
                        HStack {
                            Text("출생 시간")
                                .fontWeight(.bold)
                                .foregroundColor(.primary.opacity(0.8))
                                .padding(.leading, 5)
                            Spacer()
                            if isEditing {
                                DatePicker("", selection: $viewModel.baby.birthDate, displayedComponents: [.hourAndMinute])
                                    .labelsHidden()
                                    .frame(width: 150, alignment: .trailing)
                                    .padding(.trailing, 5)
                            } else {
                                Text(viewModel.formattedTime(viewModel.baby.birthDate))
                                    .foregroundColor(.primary.opacity(0.6))
                                    .frame(width: 150, alignment: .trailing)
                                    .padding(.trailing, 5)
                            }
                            Image(systemName: "chevron.right")
                                .foregroundColor(.primary.opacity(0.8))
                                .padding(.trailing, 18)
                        }
                    }
                    HStack {
                        Text("성별")
                            .fontWeight(.bold)
                            .foregroundColor(.primary.opacity(0.8))
                            .padding(.leading, 5)
                        Spacer()
                        if isEditing {
                            Picker("", selection: $viewModel.baby.gender) {
                                Text("남").tag(Gender.male)
                                Text("여").tag(Gender.female)
                            }
                            .pickerStyle(MenuPickerStyle())
                            .foregroundColor(.primary.opacity(0.6))
                            .frame(width: 100, alignment: .trailing)
                            .padding(.trailing, 5)
                        } else {
                            Text("\(viewModel.baby.gender == .male ? "남" : "여")")
                                .foregroundColor(.primary.opacity(0.8))
                                .frame(width: 100, alignment: .trailing)
                                .padding(.trailing, 5)
                        }
                        Image(systemName: "chevron.right")
                            .foregroundColor(.primary.opacity(0.8))
                            .padding(.trailing, 18)
                    }
                    HStack {
                        Text("키")
                            .fontWeight(.bold)
                            .foregroundColor(.primary.opacity(0.8))
                            .padding(.leading, 5)
                        Spacer()
                        if isEditing {
                            TextField("키", value: $viewModel.baby.height, formatter: NumberFormatter())
                                .keyboardType(.decimalPad)
                                .foregroundColor(.primary.opacity(0.6))
                                .font(.system(size: 17))
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100, alignment: .trailing)
                                .padding(.trailing, 5)
                        } else {
                            Text("\(String(format: "%.1f", viewModel.baby.height)) cm")
                                .foregroundColor(.primary.opacity(0.6))
                                .font(.system(size: 17))
                                .frame(width: 100, alignment: .trailing)
                                .padding(.trailing, 5)
                        }
                        Image(systemName: "chevron.right")
                            .foregroundColor(.primary.opacity(0.8))
                            .padding(.trailing, 18)
                    }
                    HStack {
                        Text("몸무게")
                            .fontWeight(.bold)
                            .foregroundColor(.primary.opacity(0.8))
                            .padding(.leading, 5)
                        Spacer()
                        if isEditing {
                            TextField("몸무게", value: $viewModel.baby.weight, formatter: NumberFormatter())
                                .keyboardType(.decimalPad)
                                .foregroundColor(.primary.opacity(0.6))
                                .font(.system(size: 17))
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100, alignment: .trailing)
                                .padding(.trailing, 5)
                        } else {
                            Text("\(String(format: "%.1f", viewModel.baby.weight)) kg")
                                .foregroundColor(.primary.opacity(0.6))
                                .font(.system(size: 17))
                                .frame(width: 100, alignment: .trailing)
                                .padding(.trailing, 5)
                        }
                        Image(systemName: "chevron.right")
                            .foregroundColor(.primary.opacity(0.8))
                            .padding(.trailing, 18)
                    }
                    HStack {
                        Text("혈액형")
                            .fontWeight(.bold)
                            .foregroundColor(.primary.opacity(0.8))
                            .padding(.leading, 5)
                        Spacer()
                        if isEditing {
                            Picker("", selection: $viewModel.baby.bloodType) {
                                Text(BloodType.A.rawValue).tag(BloodType.A)
                                Text(BloodType.B.rawValue).tag(BloodType.B)
                                Text(BloodType.AB.rawValue).tag(BloodType.AB)
                                Text(BloodType.O.rawValue).tag(BloodType.O)
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding(.trailing, 5)
                        } else {
                            Text("\(viewModel.baby.bloodType.rawValue)")
                                .foregroundColor(.primary.opacity(0.6))
                                .padding(.trailing, 5)
                        }
                        Image(systemName: "chevron.right")
                            .foregroundColor(.primary.opacity(0.8))
                            .padding(.trailing, 18)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 30)
                .background(Color(UIColor.tertiarySystemBackground))
                
                Spacer()
            }
        }
        .background(Color("customBackgroundColor"))
        .navigationTitle("\(viewModel.baby.name)님의 정보")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "완료" : "편집") {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if isEditing {
                                Task {
                                    await viewModel.saveBabyImage()
                                    await viewModel.saveProfileEdits()
                                    showAlert = true
                                }
                        }
                        isEditing.toggle()
                    }
                }
            }
        }
        .padding(.top, 20)
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
