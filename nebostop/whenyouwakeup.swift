//
//  whenyouwakeup.swift
//  nebostop
//
//  Created by 岡島結南 on 2026/03/01.
//

import SwiftUI
import SwiftData

struct whenyouwakeup: View {
    @State var selectionDate = Date()
    @State private var currentStep = 1
    @Binding var currentscreen: Screen
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelcontext
    @Query var missiondata : [MissionData]
    @State private var showAlert = false
    let totalSteps = 3
    var body: some View {
        NavigationStack{
            ZStack{
                Image("whenyouwakeup")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                Text("明日は何時に起きる？")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .lineSpacing(20)
                    .frame(maxWidth: 300, alignment: .center)
                    .offset(x:20, y:-260)
                DatePicker("Wake up time",
                           selection: $selectionDate,
                           displayedComponents:.hourAndMinute)
                .labelsHidden()
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
                    
                    Button{
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
        }
    }
    func save(){
        let newmission = MissionData(wakeuptime: selectionDate)
        //modelcontext.insert(selectionDate)
        //何を書けばいいだろう、、？
        //多分入力した日時をstructに入れる処理
        //時間だけじゃなくてデフォルトで今日の日付も入れたほうがいいのでは？
    }
}



#Preview {
    whenyouwakeup(currentscreen:.constant(.whenyouwakeup))
        .modelContainer(for: MissionData.self, inMemory: true)
}
