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
    
}

struct begining: View {
    @State private var currentscreen: Screen = .start
    @State private var selectionDate: Date = Date()
    var body: some View {
        if currentscreen == .start {
            start(currentscreen: $currentscreen)
        }else if currentscreen == .whenyouwakeup {
            whenyouwakeup(currentscreen: $currentscreen)
        }else if currentscreen == .setmission {
            setmission(currentscreen: $currentscreen)
        }
    }
}

#Preview {
    begining()
}
