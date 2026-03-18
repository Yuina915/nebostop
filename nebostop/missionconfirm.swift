//
//  missionconfirm.swift
//  nebostop
//
//  Created by 岡島結南 on 2026/03/14.
//

import SwiftUI

struct missionconfirm: View {
    @Binding var selectionDate: Date
    @Binding var inputmission: String
    var onConfirm: () -> Void
    @State private var currentStep = 1
    let totalSteps = 3
    
    var body: some View {
        ZStack{
            Image("missionconfirm")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            VStack{
                Spacer()
                Spacer()
                Spacer()
                
                VStack(spacing:30){
                    Text(inputmission)
                        .font(.largeTitle)
                        .multilineTextAlignment(.center)
                    
                    Button{
                        Haptics.impact(.medium)
                        onConfirm()
                    } label: {
                        Label("ミッションを確定", systemImage: "flag.pattern.checkered")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(.vertical, 15)
                            .padding(.horizontal, 30)
                            .background(Color(red: 253/255, green: 149/255, blue: 96/255))
                            .cornerRadius(30)
                    }
                    .padding(.bottom, 24)
                }
                .padding(.horizontal, 24)
                Spacer()
            }
        }
        .overlay {
            ProgressBarOverlay(currentStep: currentStep, totalSteps: totalSteps)
        }
    }
}

#Preview {
    missionconfirm(
        selectionDate: .constant(Date()),
        inputmission: .constant("今日のミッション1"),
        onConfirm: {}
    )
}
