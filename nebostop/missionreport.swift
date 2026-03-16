//
//  missionreport.swift
//  nebostop
//
//  Created by 岡島結南 on 2026/03/15.
//

import SwiftUI
import PhotosUI
import SwiftData

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
                ZStack{
                    Rectangle()
                        .fill(Color.white)
                        .frame(maxWidth: 300, maxHeight: 75)
                        .cornerRadius(30)
                        .overlay(
                        RoundedRectangle(cornerRadius: 30).stroke(Color(red: 149/255, green: 149/255, blue: 149/255), lineWidth: 3)
                        )
                    Text("ミッションを達成したこと\nを報告しよう！")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                        .frame(maxWidth: 300, alignment: .center)
                }
                .padding(.top, 110)
                
                
                GeometryReader { geo in
                    let pickerWidth = geo.size.width * 0.8
                    let pickerHeight = geo.size.height * 0.35
                    let noteHeight = geo.size.height * 0.1
                
                    VStack(spacing: -3){
                        ZStack{
                            Rectangle()
                                .fill(Color(red: 253/255, green: 149/255, blue: 96/255))
                                .frame(width: pickerWidth, height: noteHeight)
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
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            ZStack{
                                Rectangle()
                                    .fill(Color.white.opacity(0.12))
                                    .frame(width: pickerWidth, height: pickerHeight)
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
                                        .frame(width: pickerWidth, height: pickerHeight)
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
                                        .frame(maxWidth: pickerWidth, maxHeight: pickerHeight, alignment: .bottomTrailing)
                                        .padding(.trailing, 12)
                                        .padding(.bottom, 12)
                                }
                            }
                        }
                        .buttonStyle(.plain)
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
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
                Spacer()
            }
            .padding(.top, 20)
        }
        .overlay {
            ProgressBarOverlay(currentStep: currentStep, totalSteps: totalSteps)
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                selectedImageData = try? await newItem?.loadTransferable(type: Data.self)
            }
        }
    }
    
    private func saveReport() {
        if let latestMission = missiondata.first, latestMission.mission == inputmission {
            latestMission.reportImageData = selectedImageData
            latestMission.reportCreatedAt = Date()
        } else {
            let newMission = MissionData(
                wakeuptime: Date(),
                mission: inputmission,
                reportImageData: selectedImageData,
                reportCreatedAt: Date()
            )
            modelcontext.insert(newMission)
        }
        try? modelcontext.save()
    }
}

#Preview {
    missionreport(inputmission: .constant("今日のミッション1"), onReport: {})
}
