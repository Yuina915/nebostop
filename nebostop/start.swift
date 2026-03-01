//
//  start.swift
//  nebostop
//
//  Created by 岡島結南 on 2026/03/01.
//

import SwiftUI

struct start: View {
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
                    
                    NavigationLink{
                        whenyouwakeup()
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
        }
    }
}

#Preview {
    start()
}
