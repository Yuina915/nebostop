//
//  selectmission.swift
//  nebostop
//
//  Created by 岡島結南 on 2026/03/14.
//

import SwiftUI

struct selectmission: View {
    @Binding var selectionDate: Date
    @Binding var inputmission: String
    var onSelectMission: (String) -> Void
    @State private var currentStep = 0
    let totalSteps = 3
    let missionCount = 4
    
    var body: some View {
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
                    Text("今日のミッションはこちら！")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .lineSpacing(20)
                        .frame(maxWidth: 300, alignment: .center)
                }
                .padding(.top,140)
                Spacer()
            }
            GeometryReader { geo in
                VStack{
                    Spacer()
                    VStack(spacing: 15){
                        ForEach(0..<missionCount, id: \.self) { index in
                            let mission = "今日のミッション\(index + 1)"
                            HStack{
                                Image(systemName: "person.circle")
                                    .font(.system(size: 35, weight: .regular))
                                ZStack{
                                    Rectangle()
                                        .fill(Color(.white))
                                        .frame(width: geo.size.width * 0.40, height: geo.size.height * 0.05)
                                        .cornerRadius(10)
                                    Text(mission)
                                }
                                Button{
                                    Haptics.impact(.light)
                                    inputmission = mission
                                    onSelectMission(mission)
                                }label: {
                                    Text("これにする")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 10)
                                        .background(Color(red: 253/255, green: 149/255, blue: 96/255))
                                        .cornerRadius(30)
                                }
                                
                            }
                        }
                    }
                    .padding(20)
                    .background(Color(red: 217/255, green: 217/255, blue: 217/255))
                    .cornerRadius(15)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .offset(y: geo.size.height * 0.10)
            }
        }
        .overlay {
            ProgressBarOverlay(currentStep: currentStep, totalSteps: totalSteps)
        }
    }
}

#Preview {
    selectmission(
        selectionDate: .constant(Date()),
        inputmission: .constant(""),
        onSelectMission: { _ in }
    )
}
