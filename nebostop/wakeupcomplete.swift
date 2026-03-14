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
    @Query(sort: [SortDescriptor(\MissionData.wakeuptime, order: .reverse)])
    private var missiondata: [MissionData]
    @State private var isEditingMission = false
    @State private var editingMissionText = ""
    @State private var showToast = false

    private var displayedWakeupTimeText: String {
        selectionDate.formatted(date: .omitted, time: .shortened)
    }
    var body: some View {
        ZStack{
            Image("wakeupcomplete")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
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
                .padding(.vertical, 150)
                Spacer()
            }
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
            .padding(.vertical, 120)
            
        }
        .overlay(alignment: .bottom) {
            if showToast {
                Text("起床時間とミッションが設定されました")
                    .font(.body.bold())
                    .foregroundColor(.white)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 22)
                    .background(Color(red: 198/255, green: 236/255, blue: 100/255))
                    .clipShape(Capsule())
                    .padding(.bottom, 80)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear {
            editingMissionText = inputmission
            withAnimation(.easeInOut(duration: 0.25)) {
                showToast = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showToast = false
                }
            }
        }
        .onChange(of: inputmission) { newValue in
            if !isEditingMission {
                editingMissionText = newValue
            }
        }
        .onChange(of: selectionDate) { _ in
            saveWakeupTime()
        }
    }

    private func saveWakeupTime() {
        if let latestMission = missiondata.first {
            latestMission.wakeuptime = selectionDate
            try? modelcontext.save()
        } else {
            let newMission = MissionData(wakeuptime: selectionDate, mission: inputmission)
            modelcontext.insert(newMission)
            try? modelcontext.save()
        }
    }

    private func saveMission() {
        if let latestMission = missiondata.first {
            latestMission.mission = inputmission
            try? modelcontext.save()
        } else {
            let newMission = MissionData(wakeuptime: selectionDate, mission: inputmission)
            modelcontext.insert(newMission)
            try? modelcontext.save()
        }
    }
}

#Preview {
    wakeupcomplete(selectionDate: .constant(Date()), inputmission: .constant(""), currentscreen:.constant(.wakeupcomplete))
}
