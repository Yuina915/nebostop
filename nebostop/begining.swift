//
//  begining.swift
//  nebostop
//
//  Created by 岡島結南 on 2026/03/02.
//

import SwiftUI
import UIKit

enum Screen {
    case start
    case whenyouwakeup
    case setmission
    case wakeupcomplete
}

struct begining: View {
    @Binding var currentscreen: Screen
    @Binding var selectionDate: Date
    @Binding var inputmission: String
    @Binding var wakeupResetToken: UUID
    @State private var previousScreen: Screen? = nil
    var body: some View {
        Group {
            if currentscreen == .start {
                start(currentscreen: $currentscreen, selectionDate: $selectionDate)
            }else if currentscreen == .whenyouwakeup {
                whenyouwakeup(selectionDate: $selectionDate, currentscreen: $currentscreen)
            }else if currentscreen == .setmission {
                setmission(inputmission: $inputmission, currentscreen: $currentscreen)
            }else if currentscreen == .wakeupcomplete {
                wakeupcomplete(selectionDate: $selectionDate, inputmission: $inputmission, currentscreen: $currentscreen)
            }
        }
        .onAppear {
            previousScreen = currentscreen
        }
        .onChange(of: currentscreen) { newValue in
            if previousScreen == .setmission && newValue == .wakeupcomplete {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            }
            if newValue == .wakeupcomplete {
                wakeupResetToken = UUID()
            }
            previousScreen = newValue
        }
    }
}

#Preview {
    begining(
        currentscreen: .constant(.start),
        selectionDate: .constant(Date()),
        inputmission: .constant(""),
        wakeupResetToken: .constant(UUID())
    )
}
