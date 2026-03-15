//
//  ToastOverlay.swift
//  nebostop
//
//  Created by 岡島結南 on 2026/03/15.
//

import SwiftUI

struct ToastOverlay: View {
    let text: String
    let widthRatio: CGFloat
    let bottomPadding: CGFloat
    let backgroundColor: Color

    init(text: String, widthRatio: CGFloat = 0.9, bottomPadding: CGFloat = 80, backgroundColor: Color = Color(red: 198/255, green: 236/255, blue: 100/255)) {
        self.text = text
        self.widthRatio = widthRatio
        self.bottomPadding = bottomPadding
        self.backgroundColor = backgroundColor
    }

    var body: some View {
        GeometryReader { geo in
            VStack {
                Spacer()
                Text(text)
                .font(.body.bold())
                .foregroundColor(.white)
                .padding(.vertical, 14)
                .padding(.horizontal, 22)
                .background(backgroundColor)
                .clipShape(Capsule())
                .frame(width: geo.size.width * widthRatio)
                .padding(.bottom, bottomPadding)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

#Preview {
    ZStack {
        Color.white.ignoresSafeArea()
        ToastOverlay(text: "グループ名 が作成されました")
    }
}
