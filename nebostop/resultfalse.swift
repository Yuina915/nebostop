//
//  resultfalse.swift
//  nebostop
//
//  Created by 岡島結南 on 2026/03/14.
//

import SwiftUI

struct resultfalse: View {
    @Binding var selectionDate: Date
    @Binding var inputmission: String
    @Binding var currentscreen: Screen
    var actualWakeupTime: Date?
    var onChallenge: () -> Void

    private var resultMessage: String {
        "起床失敗"
    }

    private var resultTitle: String {
        "ざんねん…"
    }

    private var targetTimeText: String {
        selectionDate.formatted(date: .omitted, time: .shortened)
    }
    private var actualTimeText: String {
        guard let actual = actualWakeupTime else {
            return "--:--"
        }
        return actual.formatted(date: .omitted, time: .shortened)
    }
    private var diffTimeText: String {
        guard let actual = actualWakeupTime else {
            return "--:--"
        }
        let diffMinutes = minutesSinceMidnight(actual) - minutesSinceMidnight(selectionDate)
        let sign = diffMinutes >= 0 ? "+" : "-"
        let absMinutes = abs(diffMinutes)
        let hours = absMinutes / 60
        let minutes = absMinutes % 60
        return String(format: "%@%02d:%02d", sign, hours, minutes)
    }

    var body: some View {
        ZStack{
            Image("resultfalse")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            GeometryReader { geo in
                Button{
                    Haptics.impact(.medium)
                    onChallenge()
                } label: {
                    ZStack{
                        Circle()
                            .fill(Color(red: 253/255, green: 149/255, blue: 96/255))
                            .frame(width: 250, height: 250)
                        Text("ミッションに\nチャレンジ")
                            .font(.title.bold())
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .frame(maxWidth: 200)
                    }
                }
                .position(x: geo.size.width / 2, y: geo.size.height * 2 / 3)
            }
            
            VStack{
                VStack(alignment: .leading, spacing: 10){
                    Text(resultTitle)
                        .font(.title2)
                        .frame(maxWidth: 250, alignment: .topLeading)
                    Text(resultMessage)
                        .font(.largeTitle .bold())
                        .frame(maxWidth: 250, alignment: .trailing)
                }
                .padding(.top, 110)

                Spacer()
                
                
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    private func minutesSinceMidnight(_ date: Date) -> Int {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
        return (comps.hour ?? 0) * 60 + (comps.minute ?? 0)
    }
}

#Preview {
    resultfalse(
        selectionDate: .constant(Date()),
        inputmission: .constant(""),
        currentscreen: .constant(.wakeupcomplete),
        actualWakeupTime: Date(),
        onChallenge: {}
    )
}
