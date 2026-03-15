//
//  whenyouwakeup.swift
//  nebostop
//
//  Created by 岡島結南 on 2026/03/01.
//

import SwiftUI
import SwiftData

struct whenyouwakeup: View {
    @Binding var selectionDate: Date
    @State private var currentStep = 1
    @Binding var currentscreen: Screen
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelcontext
    @Query var missiondata : [MissionData]
    @State private var showAlert = false
    @AppStorage("hasDeclaredWakeupTime") private var hasDeclaredWakeupTime = false
    let totalSteps = 3
    var body: some View {
        NavigationStack{
            ZStack{
                Image("whenyouwakeup2")
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
                        Text("明日は何時に起きる？")
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .lineSpacing(20)
                            .frame(maxWidth: 300, alignment: .center)
                    }
                    .padding(.top,140)
                    Spacer()
                }

                DatePicker("Wake up time",
                           selection: $selectionDate,
                           displayedComponents:.hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
                VStack{
                    Spacer()
                    
                    Button{
                        save()
                        currentscreen = .setmission
                    } label: {
                        Label("この時間に起きる", systemImage: "alarm.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(.vertical, 15)
                            .padding(.horizontal, 30)
                            .background(Color(red: 253/255, green: 149/255, blue: 96/255))
                            .cornerRadius(30)
                    }
                    .padding(.vertical, 200)
                }
            }
            .overlay {
                ProgressBarOverlay(currentStep: currentStep, totalSteps: totalSteps)
            }
        }
    }
    func save(){
        if let latestMission = missiondata.first,
           latestMission.mission.isEmpty,
           latestMission.actualwakeuptime == nil {
            latestMission.wakeuptime = selectionDate
        } else {
            let newmission = MissionData(wakeuptime: selectionDate)
            modelcontext.insert(newmission)
        }
        try? modelcontext.save()
        hasDeclaredWakeupTime = true
    }
}



#Preview {
    whenyouwakeup(selectionDate: .constant(Date()), currentscreen:.constant(.whenyouwakeup))
        .modelContainer(for: MissionData.self, inMemory: true)
}
