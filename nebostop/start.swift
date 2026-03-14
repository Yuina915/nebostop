//
//  start.swift
//  nebostop
//
//  Created by 岡島結南 on 2026/03/01.
//

import SwiftUI

struct start: View {
    @State private var currentStep = 0
    @Binding var currentscreen: Screen
    @Binding var selectionDate : Date
    let totalSteps = 3
    var body: some View {
        NavigationStack{
            ZStack{
                Image("start")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                VStack(spacing:30){
                    
                    
                    Text("明日は何時に起きるのか\n宣言しよう！")
                        .font(.title2 .bold())
                        .multilineTextAlignment(.center)
                        .lineSpacing(20)
                        .frame(maxWidth: 300, alignment: .center)
                    
                    Button{
                        currentscreen = .whenyouwakeup
                    } label: {
                        Text("宣言する！")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(.vertical, 15)
                            .padding(.horizontal, 30)
                            .background(Color(red: 253/255, green: 149/255, blue: 96/255))
                            .cornerRadius(30)
                    }
                }
                .offset(y:-130)
            }
            .overlay {
                ProgressBarOverlay(currentStep: currentStep, totalSteps: totalSteps)
            }
        }
    }
}

#Preview {
    start(currentscreen: .constant(.start), selectionDate: .constant(Date()))
}
