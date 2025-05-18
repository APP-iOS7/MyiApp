//
//  UIDatePickerActionSheet.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-12.
//

import SwiftUI

struct UIDatePickerActionSheet: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var selectedDate: Date

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        guard isPresented, uiViewController.presentedViewController == nil else { return }

        let alert = UIAlertController(title: "", message: String(repeating: "\n", count: 9), preferredStyle: .actionSheet)

        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.locale = .init(identifier: "ko_KR")
        picker.date = selectedDate
        picker.maximumDate = Date()
        picker.preferredDatePickerStyle = .wheels
        alert.view.addSubview(picker)

        alert.addAction(UIAlertAction(title: "완료", style: .default, handler: { _ in
            selectedDate = picker.date
            isPresented = false
        }))

        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { _ in
            isPresented = false
        }))

        DispatchQueue.main.async {
            uiViewController.present(alert, animated: true)
        }
    }
}
