//
//  wakeupcomplete.swift
//  nebostop
//
//  Created by 岡島結南 on 2026/03/02.
//

import SwiftUI

struct wakeupcomplete: View {
    @Binding var selectionDate: Date
    @Binding var inputmission: String
    @Binding var currentscreen: Screen

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
                VStack{
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
                    .frame(height:1)
                    .cornerRadius(10)
                    .padding(.horizontal, 30)
                
                VStack{
                    HStack{
                        Text("ミッション")
                            .font(.title2)
                        Spacer()
                        Text(inputmission.isEmpty ? "未設定" : inputmission)
                            .lineLimit(2)
                            .multilineTextAlignment(.trailing)
                        
                    }
                    .padding(.horizontal, 50)
                    .padding(.vertical, 10)
                }
                
                Rectangle()
                    .frame(height:1)
                    .cornerRadius(10)
                    .padding(.horizontal, 50)
                    .padding(.vertical, 10)
            }
            .padding(.vertical, 180)
            
            Button{
                currentscreen = .start
            } label: {
                Label("この時間に起きる", systemImage: "alarm.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(.vertical, 15)
                    .padding(.horizontal, 30)
                    .background(Color(red: 253/255, green: 149/255, blue: 96/255))
                    .cornerRadius(30)
            }
        }
    }
}

#Preview {
    wakeupcomplete(selectionDate: .constant(Date()), inputmission: .constant(""), currentscreen:.constant(.wakeupcomplete))
}
