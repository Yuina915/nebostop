//
//  missionreport.swift
//  nebostop
//
//  Created by 岡島結南 on 2026/03/15.
//

import SwiftUI
import PhotosUI
import SwiftData
import UIKit

struct missionreport: View {
    @Binding var inputmission: String
    @Environment(\.modelContext) private var modelcontext
    @Query(sort: [SortDescriptor(\MissionData.createdAt, order: .reverse)])
    private var missiondata: [MissionData]
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var currentStep = 2
    let totalSteps = 3
    var onReport: () -> Void
    @State private var isShowingCamera = false
    @State private var isShowingPhotoLibrary = false

    private var canReport: Bool {
        selectedImageData != nil
    }
    
    var body: some View {
        ZStack{
            Image("setmission2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            VStack(spacing: 16){
                Text("ミッションを達成したこと\nを報告しよう！")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.vertical, 24)
                    .frame(maxWidth: 280, alignment: .center)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color(red: 149/255, green: 149/255, blue: 149/255), lineWidth: 3)
                            )
                    )
                    .padding(.top, 110)
                
                let pickerHeight: CGFloat = 240
                let noteHeight: CGFloat = 60
                
                VStack(spacing: -3){
                    Spacer()
                    ZStack{
                        Rectangle()
                            .fill(Color(red: 253/255, green: 149/255, blue: 96/255))
                            .frame(maxWidth: .infinity, minHeight: noteHeight, maxHeight: noteHeight)
                            .clipShape(
                                UnevenRoundedRectangle(
                                    cornerRadii: RectangleCornerRadii(
                                        topLeading: 18,
                                        bottomLeading: 0,
                                        bottomTrailing: 0,
                                        topTrailing: 18
                                    )
                                )
                            )
                            .overlay(
                                UnevenRoundedRectangle(
                                    cornerRadii: RectangleCornerRadii(
                                        topLeading: 18,
                                        bottomLeading: 0,
                                        bottomTrailing: 0,
                                        topTrailing: 18
                                    )
                                )
                                .stroke(Color(red: 253/255, green: 149/255, blue: 96/255), lineWidth: 3)
                            )
                        Text(inputmission)
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    Menu {
                        Button {
                            isShowingPhotoLibrary = true
                        } label: {
                            Label("ライブラリから選ぶ", systemImage: "photo.on.rectangle")
                        }
                        Button {
                            isShowingCamera = true
                        } label: {
                            Label("カメラで撮影", systemImage: "camera.fill")
                        }
                    } label: {
                        ZStack{
                            Rectangle()
                                .fill(Color.white.opacity(0.12))
                                .frame(maxWidth: .infinity, minHeight: pickerHeight, maxHeight: pickerHeight)
                                .clipShape(
                                    UnevenRoundedRectangle(
                                        cornerRadii: RectangleCornerRadii(
                                            topLeading: 0,
                                            bottomLeading: 18,
                                            bottomTrailing: 18,
                                            topTrailing: 0
                                        )
                                    )
                                )
                                .overlay(
                                    UnevenRoundedRectangle(
                                        cornerRadii: RectangleCornerRadii(
                                            topLeading: 0,
                                            bottomLeading: 18,
                                            bottomTrailing: 18,
                                            topTrailing: 0
                                        )
                                    )
                                    .stroke(Color(red: 253/255, green: 149/255, blue: 96/255), lineWidth: 3)
                                )
                            if let data = selectedImageData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: .infinity, minHeight: pickerHeight, maxHeight: pickerHeight)
                                    .clipped()
                                    .clipShape(
                                        UnevenRoundedRectangle(
                                            cornerRadii: RectangleCornerRadii(
                                                topLeading: 0,
                                                bottomLeading: 18,
                                                bottomTrailing: 18,
                                                topTrailing: 0
                                            )
                                        )
                                    )
                            } else {
                                Image(systemName: "photo.badge.plus")
                                    .font(.title3.weight(.bold))
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                                    .background(Color(red: 253/255, green: 149/255, blue: 96/255))
                                    .clipShape(Circle())
                            }
                            if selectedImageData != nil {
                                Text("変更")
                                    .font(.caption.bold())
                                    .foregroundColor(.white)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 20)
                                    .background(Color(red: 253/255, green: 149/255, blue: 96/255))
                                    .cornerRadius(16)
                                    .frame(maxWidth: .infinity, maxHeight: pickerHeight, alignment: .bottomTrailing)
                                    .padding(.trailing, 12)
                                    .padding(.bottom, 12)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .photosPicker(isPresented: $isShowingPhotoLibrary, selection: $selectedItem, matching: .images)
                    Button{
                        saveReport()
                        Haptics.notify(.success)
                        onReport()
                    } label: {
                        Label("報告", systemImage: "paperplane.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(.vertical, 15)
                            .padding(.horizontal, 100)
                            .background(
                                canReport
                                ? Color(red: 253/255, green: 149/255, blue: 96/255)
                                : Color.gray.opacity(0.5)
                            )
                            .cornerRadius(30)
                    }
                    .disabled(!canReport)
                    .padding(20)
                    Spacer()
                }
                .padding(.horizontal, 32)
            }
        }
        .overlay(alignment: .top) {
            ProgressBarOverlay(currentStep: currentStep, totalSteps: totalSteps,)
        }
        .fullScreenCover(isPresented: $isShowingCamera) {
            CameraCapture(imageData: $selectedImageData)
                .ignoresSafeArea()
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                selectedImageData = try? await newItem?.loadTransferable(type: Data.self)
            }
        }
    }
    
    private func saveReport() {
        guard let imageData = selectedImageData else { return }
        let targetMission = missiondata.first { mission in
            mission.actualwakeuptime != nil && mission.reportCreatedAt == nil
        }
        guard let missionToUpdate = targetMission else {
            print("missionreport saveReport: no mission available to attach report")
            return
        }
        missionToUpdate.reportImageData = imageData
        missionToUpdate.reportCreatedAt = Date()
        try? modelcontext.save()
    }
}

struct CameraCapture: UIViewControllerRepresentable {
    @Binding var imageData: Data?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        picker.modalPresentationStyle = .fullScreen
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraCapture

        init(parent: CameraCapture) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            defer {
                parent.dismiss()
            }
            guard let image = info[.originalImage] as? UIImage else {
                return
            }
            parent.imageData = image.jpegData(compressionQuality: 0.8)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    missionreport(inputmission: .constant("今日のミッション1"), onReport: {})
}
