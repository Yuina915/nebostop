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
    @Binding var currentscreen: Screen
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelcontext
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
                    
                    
                    
                    Button{
                        currentscreen = .wakeupcomplete
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
}

#Preview {
    setmission(currentscreen: .constant(.setmission))
}
