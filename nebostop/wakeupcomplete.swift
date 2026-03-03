//
//  wakeupcomplete.swift
//  nebostop
//
//  Created by 岡島結南 on 2026/03/02.
//

import SwiftUI

struct wakeupcomplete: View {
    var body: some View {
        ZStack{
            Image("wakeupcomplete")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            Text("あしたは")
                .font(.title2)
                .multilineTextAlignment(.center)
                .lineSpacing(20)
                .frame(maxWidth: 300, alignment: .center)
                .offset(x:20, y:-260)
            
        }
    }
}

#Preview {
    wakeupcomplete()
}
