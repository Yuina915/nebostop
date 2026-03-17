//
//  wakeupcomplete.swift
//  nebostop
//
//  Created by 岡島結南 on 2026/03/02.
//

import SwiftUI
import SwiftData

struct wakeupcomplete: View {
    @Binding var selectionDate: Date
    @Binding var inputmission: String
    @Binding var currentscreen: Screen
    @Environment(\.modelContext) private var modelcontext
    @EnvironmentObject private var toastManager: ToastManager
    @Query(sort: [SortDescriptor(\MissionData.createdAt, order: .reverse)])
    private var missiondata: [MissionData]
    @State private var isEditingMission = false
    @State private var editingMissionText = ""
    @State private var hasAppeared = false
    @AppStorage("profileImageData") private var profileImageData: Data?
    @AppStorage("currentUserIconName") private var currentUserIconName = "person.circle"

    private var displayedWakeupTimeText: String {
        selectionDate.formatted(date: .omitted, time: .shortened)
    }
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                Image("wakeupcomplete")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                VStack{
                    Spacer()
                    VStack{
                        VStack(alignment: .leading, spacing: 10){
                            Text("あしたは")
                                .font(.title2)
                                .frame(maxWidth: 300, alignment: .topLeading)
                            Text(displayedWakeupTimeText)
                                .font(.largeTitle .bold())
                                .frame(maxWidth: 300, alignment: .center)
                            Text("に起きよう！")
                                .font(.title2)
                                .frame(maxWidth: 300, alignment: .bottomTrailing)
                        }
                    }
                    .frame(maxWidth: geometry.size.width * 0.8,maxHeight: geometry.size.height * 0.2)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color(red: 149/255, green: 149/255, blue: 149/255), lineWidth: 3)
                            )
                    )
                    .padding(.top, geometry.size.height * 0.1)
                    VStack{
                        Spacer()
                        Rectangle()
                            .foregroundColor(Color.black)
                            .frame(height:1)
                            .cornerRadius(10)
                            .padding(.horizontal, 30)
                        
                        HStack{
                            Text("起床時刻")
                                .font(.title2)
                            Spacer()
                            DatePicker("Wake up time",
                                       selection: $selectionDate,
                                       displayedComponents:.hourAndMinute)
                            .labelsHidden()
                            
                            
                        }
                        .padding(.horizontal, 50)
                        .padding(.vertical, 10)
                        
                        Rectangle()
                            .foregroundColor(Color.black)
                            .frame(height:1)
                            .cornerRadius(10)
                            .padding(.horizontal, 30)
                        
                        VStack{
                            HStack{
                                Text("ミッション")
                                    .font(.title2)
                                Spacer()
                                Button{
                                    if isEditingMission {
                                        inputmission = editingMissionText.trimmingCharacters(in: .whitespacesAndNewlines)
                                        saveMission()
                                        isEditingMission = false
                                    } else {
                                        editingMissionText = inputmission
                                        isEditingMission = true
                                    }
                                }label: {
                                    Image(systemName: isEditingMission ? "checkmark" : "pencil.line")
                                        .font(.title3.weight(.bold))
                                        .foregroundColor(.white)
                                        .frame(width: 40, height: 40)
                                        .background(Color(red: 253/255, green: 149/255, blue: 96/255))
                                        .clipShape(Circle())
                                    
                                }
                                
                            }
                            .padding(.horizontal, 50)
                            .padding(.vertical, 10)
                            
                            VStack(alignment: .center, spacing: 0) {
                                if isEditingMission {
                                    TextField("ミッションを入力", text: $editingMissionText, axis: .vertical)
                                        .lineLimit(1...4)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 10)
                                        .frame(maxWidth: .infinity, minHeight: 52, alignment: .top)
                                        .background(Color.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 14))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(Color.gray.opacity(0.35), lineWidth: 1)
                                        )
                                } else {
                                    Text(inputmission.isEmpty ? "未設定" : inputmission)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.center)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                }
                            }
                            .frame(maxWidth: .infinity, minHeight: 54, alignment: .top)
                            .padding(.horizontal, 50)
                        }
                        
                        Rectangle()
                            .foregroundColor(Color.black)
                            .frame(height:1)
                            .cornerRadius(10)
                            .padding(.horizontal, 50)
                            .padding(.vertical, 10)
                    }
                }
                .padding(.bottom, geometry.size.height * 0.2)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .onAppear {
                editingMissionText = inputmission
                DispatchQueue.main.async {
                    hasAppeared = true
                }
            }
            .onChange(of: inputmission) { newValue in
                if !isEditingMission {
                    editingMissionText = newValue
                }
            }
            .onChange(of: selectionDate) { _ in
                guard hasAppeared else { return }
                saveWakeupTime()
            }
        }
    }

    private func saveWakeupTime() {
        if let pending = missiondata.first(where: { $0.actualwakeuptime == nil }) {
            pending.wakeuptime = selectionDate
            pending.createdAt = Date()
            pending.enteredByIconName = currentUserIconName
            pending.enteredByProfileImageData = profileImageData
            try? modelcontext.save()
        } else {
            let newMission = MissionData(
                wakeuptime: selectionDate,
                mission: inputmission,
                createdAt: Date(),
                enteredByIconName: currentUserIconName,
                enteredByProfileImageData: profileImageData
            )
            modelcontext.insert(newMission)
            try? modelcontext.save()
        }
        toastManager.show("更新されました")
    }

    private func saveMission() {
        if let pending = missiondata.first(where: { $0.actualwakeuptime == nil }) {
            pending.mission = inputmission
            pending.createdAt = Date()
            pending.enteredByIconName = currentUserIconName
            pending.enteredByProfileImageData = profileImageData
            try? modelcontext.save()
        } else {
            let newMission = MissionData(
                wakeuptime: selectionDate,
                mission: inputmission,
                createdAt: Date(),
                enteredByIconName: currentUserIconName,
                enteredByProfileImageData: profileImageData
            )
            modelcontext.insert(newMission)
            try? modelcontext.save()
        }
        toastManager.show("更新されました")
    }
}

#Preview {
    wakeupcomplete(selectionDate: .constant(Date()), inputmission: .constant(""), currentscreen:.constant(.wakeupcomplete))
        .environmentObject(ToastManager())
}
