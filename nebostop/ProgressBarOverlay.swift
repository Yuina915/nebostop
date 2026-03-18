
//  ProgressBarOverlay.swift
//  nebostop
//
//  Created by 岡島結南 on 2026/03/15.
//

import SwiftUI

struct ProgressBarOverlay: View {
    let currentStep: Int
    let totalSteps: Int
    let yRatio: CGFloat
    let widthRatio: CGFloat

    init(currentStep: Int, totalSteps: Int, yRatio: CGFloat = 0.10, widthRatio: CGFloat = 0.7) {
        self.currentStep = currentStep
        self.totalSteps = totalSteps
        self.yRatio = yRatio
        self.widthRatio = widthRatio
    }

    var body: some View {
        let barWidth = UIScreen.main.bounds.width * widthRatio
        let topOffset = UIScreen.main.bounds.height * yRatio

        HStack(spacing: 10) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Rectangle()
                    .fill(index == currentStep ? Color.orange : Color.gray.opacity(0.3))
                    .frame(height: 6)
                    .cornerRadius(3)
            }
        }
        .frame(width: barWidth)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, topOffset)
        .allowsHitTesting(false)
    }
}

#Preview {
    ZStack {
        Color.white.ignoresSafeArea()
        ProgressBarOverlay(currentStep: 1, totalSteps: 3)
    }
}
