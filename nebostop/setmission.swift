//
//  setmission.swift
//  nebostop
//
//  Created by 岡島結南 on 2026/03/01.
//

import SwiftUI
import SwiftData

struct setmission: View {
    @State private var currentStep = 2
    @Binding var inputmission: String
    @Binding var currentscreen: Screen
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelcontext
    @AppStorage("debugSaveMessage") private var debugSaveMessage: String = ""
    @AppStorage("hasDeclaredWakeupTime") private var hasDeclaredWakeupTime = false
    @Query(sort: [SortDescriptor(\MissionData.createdAt, order: .reverse)])
    var missiondata: [MissionData]
    let totalSteps = 3
    var body: some View {
        NavigationStack{
            ZStack{
                Image("setmission2")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                VStack{
                    ZStack{
                        Rectangle()
                            .fill(Color.white)
                            .frame(maxWidth: 300, maxHeight: 65)
                            .cornerRadius(30)
                            .overlay(
                            RoundedRectangle(cornerRadius: 30).stroke(Color(red: 149/255, green: 149/255, blue: 149/255), lineWidth: 3)
                            )
                        Text("ミッションを設定しよう！")
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .lineSpacing(20)
                            .frame(maxWidth: 300, alignment: .center)
                    }
                    .padding(.top, 140)
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
                            hasDeclaredWakeupTime = true
                            currentscreen = .wakeupcomplete
                        } label: {
                            Image(systemName: "paperplane.fill")
                                .font(.title3.weight(.bold))
                                .foregroundColor(.white)
                                .frame(width: 48, height: 48)
                                .background(Color(red: 253/255, green: 149/255, blue: 96/255))
                                .clipShape(Circle())
                        }
                        .padding(6)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 200)
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
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear {
            if let latestMission = missiondata.first(where: { $0.actualwakeuptime == nil }) {
                inputmission = latestMission.mission
            } else {
                inputmission = ""
            }
        }
    }
    
    func saveMission() {
        let trimmed = inputmission.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let pending = missiondata.first(where: { $0.actualwakeuptime == nil }) {
            pending.mission = trimmed
            pending.createdAt = Date()
        } else {
            let newMission = MissionData(mission: trimmed, createdAt: Date())
            modelcontext.insert(newMission)
        }
        
        try? modelcontext.save()
    }
}

#Preview {
    setmission(inputmission: .constant(""), currentscreen: .constant(.setmission))
}
