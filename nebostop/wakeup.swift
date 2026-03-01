//
//  wakeup.swift
//  nebostop
//
//  Created by 岡島結南 on 2026/03/01.
//

import SwiftUI

struct wakeup: View {
    var body: some View {
        NavigationStack{
            ZStack{
                Image("wakeup")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                VStack{
                    Button{
                        
                    } label: {
                        ZStack{
                            Image("sun")
                                .resizable()
                                .scaledToFit()
                                .ignoresSafeArea()
                            Text("おはよう")
                                .font(.largeTitle .bold())
                                .multilineTextAlignment(.center)
                                .lineSpacing(20)
                                .frame(maxWidth: 300, alignment: .center)
                                .foregroundStyle(Color(.white))
                        }
                    }
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    wakeup()
}
