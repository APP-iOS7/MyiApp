import SwiftUI
import FirebaseFirestore

class EditRecordViewModel: ObservableObject {
    @Published var record: Record
    @Published var isLeftMinutesPickerActionSheetPresent = false
    @Published var isRightMinutesPickerActionSheetPresent = false
    @Published var isMLPickerActionSheetPresent = false
    @Published var isTMPickerActionSheetPresent = false
    let caregiverManager = CaregiverManager.shared
    
    init(record: Record) {
        self.record = record
    }
    
    var navigationTitle: String {
        switch record.title {
            case .formula, .babyFood, .pumpedMilk, .breastfeeding:
                return "수유/이유식 기록"
            case .diaper:
                return "기저귀 기록"
            case .sleep:
                return "수면 기록"
            case .heightWeight:
                return "키/몸무게 기록"
            case .bath:
                return "목욕 기록"
            case .snack:
                return "간식 기록"
            case .temperature, .medicine, .clinic:
                return "건강 관리 기록"
            case .poop, .pee, .pottyAll:
                return "배변 기록"
        }
    }

    func updateRecordTitle(_ title: TitleCategory) {
        record.title = title
        record.content = nil
        record.mlAmount = nil
        record.breastfeedingLeftMinutes = nil
        record.temperature = nil
        record.weight = nil
        record.height = nil
    }
    
    func saveRecord() {
        let babyId = caregiverManager.selectedBaby?.id.uuidString ?? ""
        let _ = Firestore.firestore().collection("babies").document(babyId).collection("records").document(record.id.uuidString).setData(from: record)
    }
    
    func deleteRecord() {
        let babyId = caregiverManager.selectedBaby?.id.uuidString ?? ""
        let _ = Firestore.firestore().collection("babies").document(babyId).collection("records").document(record.id.uuidString).delete { error in
            print(error ?? "")
        }
    }
} 
