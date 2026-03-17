//
//  setmission.swift
//  nebostop
//
//  Created by 岡島結南 on 2026/03/01.
//

import SwiftUI
import SwiftData
import UIKit

struct setmission: View {
    @State private var currentStep = 2
    @Binding var inputmission: String
    @Binding var selectionDate: Date
    @Binding var currentscreen: Screen
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelcontext
    @EnvironmentObject private var toastManager: ToastManager
    @EnvironmentObject private var wakeupState: WakeupState
    @AppStorage("debugSaveMessage") private var debugSaveMessage: String = ""
    @AppStorage("hasDeclaredWakeupTime") private var hasDeclaredWakeupTime = false
    @AppStorage("profileImageData") private var profileImageData: Data?
    @AppStorage("currentUserIconName") private var currentUserIconName = "person.circle"
    @Query(sort: [SortDescriptor(\MissionData.createdAt, order: .reverse)])
    var missiondata: [MissionData]
    let totalSteps = 3
    private var canSaveMission: Bool {
        !inputmission.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    @State private var keyboardHeight: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                ZStack{
                    Image("setmission2")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                    VStack{
                        Text("ミッションを設定しよう！")
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .lineSpacing(8)
                            .frame(maxWidth: geometry.size.width * 0.7)
                            .padding(.vertical, 24)
                            .padding(.horizontal, 24)
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 30)
                                            .stroke(Color(red: 149/255, green: 149/255, blue: 149/255), lineWidth: 3)
                                    )
                            )
                            .padding(.top, geometry.size.height * 0.17)
                        Spacer()
                    }
                    VStack{
                        Spacer()
                        
                        ZStack (alignment: .trailing){
                            TextField("ミッションを入力", text: $inputmission, axis: .vertical)
                                .lineLimit(1...4)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .frame(minHeight: 60)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 30))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color.gray.opacity(0.35), lineWidth: 1)
                                )
                            
                            Button{
                                saveMission()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                                    currentscreen = .wakeupcomplete
                                }
                            } label: {
                                Image(systemName: "paperplane.fill")
                                    .font(.title3.weight(.bold))
                                    .foregroundColor(.white)
                                    .frame(width: 48, height: 48)
                                    .background(canSaveMission ? Color(red: 253/255, green: 149/255, blue: 96/255) : Color.gray.opacity(0.6))
                                    .clipShape(Circle())
                            }
                            .padding(6)
                            .disabled(!canSaveMission)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, keyboardHeight > 0 ? 10 : 200)
                        .padding(.bottom, keyboardHeight)
//                        .animation(.easeOut(duration: 0.25), value: keyboardHeight)
                    }
                }
                .overlay {
                    ProgressBarOverlay(currentStep: currentStep, totalSteps: totalSteps)
                }
                .overlay(alignment: .bottom) {
                    if !debugSaveMessage.isEmpty {
                        Text(debugSaveMessage)
                            .font(.caption.bold())
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.black.opacity(0.7))
                            .clipShape(Capsule())
                            .padding(.bottom, 12)
                    }
                }
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear {
            if let latestMission = missiondata.first(where: { $0.actualwakeuptime == nil }) {
                inputmission = latestMission.mission
            } else {
                inputmission = ""
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                keyboardHeight = frame.height
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            keyboardHeight = 0
        }
    }

    func saveMission() {
        let trimmed = inputmission.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        if let pending = missiondata.first(where: { $0.actualwakeuptime == nil }) {
            pending.wakeuptime = selectionDate
            pending.mission = trimmed
            pending.createdAt = Date()
            pending.enteredByIconName = currentUserIconName
            pending.enteredByProfileImageData = profileImageData
        } else {
            let newMission = MissionData(
                wakeuptime: selectionDate,
                mission: trimmed,
                createdAt: Date(),
                enteredByIconName: currentUserIconName,
                enteredByProfileImageData: profileImageData
            )
            modelcontext.insert(newMission)
        }

        try? modelcontext.save()
        wakeupState.reset()
        toastManager.show("ミッションが保存されました")
        hasDeclaredWakeupTime = true
        WakeupFollowupManager.shared.scheduleFollowup(after: selectionDate)
    }
}

#Preview {
    setmission(inputmission: .constant(""), selectionDate: .constant(Date()), currentscreen: .constant(.setmission))
        .environmentObject(ToastManager())
        .environmentObject(WakeupState())
}
