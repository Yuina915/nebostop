//
//  begining.swift
//  nebostop
//
//  Created by 岡島結南 on 2026/03/02.
//

import SwiftUI

enum Screen {
    case start
    case whenyouwakeup
    case setmission
    case wakeupcomplete
}

struct begining: View {
    @State private var currentscreen: Screen = .start
    @State private var selectionDate: Date = Date()
    @State private var inputmission: String = ""
    var body: some View {
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
}

#Preview {
    begining()
}
