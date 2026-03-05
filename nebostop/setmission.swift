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
    @Query(sort: [SortDescriptor(\MissionData.wakeuptime, order: .reverse)])
    var missiondata: [MissionData]
    let totalSteps = 3
    var body: some View {
        NavigationStack{
            ZStack{
                Image("setmission")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                Text("ミッションを設定しよう！")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .lineSpacing(20)
                    .frame(maxWidth: 300, alignment: .center)
                    .offset(x:20, y:-260)
                VStack{
                    HStack(spacing: 10) {
                        ForEach(0..<totalSteps, id: \.self) { index in
                            Rectangle()
                                .fill(index == currentStep ? Color.orange : Color.gray.opacity(0.3))
                                .frame(height: 6)
                                .cornerRadius(3)
                        }
                    }
                    .padding(70)
                    
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
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear {
            if let latestMission = missiondata.first {
                inputmission = latestMission.mission
            }
        }
    }
    
    func saveMission() {
        let trimmed = inputmission.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let latestMission = missiondata.first {
            latestMission.mission = trimmed
        } else {
            let newMission = MissionData(mission: trimmed)
            modelcontext.insert(newMission)
        }
        
        try? modelcontext.save()
    }
}

#Preview {
    setmission(inputmission: .constant(""), currentscreen: .constant(.setmission))
}
