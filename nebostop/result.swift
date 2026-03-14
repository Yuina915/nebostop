//
//  result.swift
//  nebostop
//
//  Created by 岡島結南 on 2026/03/15.
//

import SwiftUI

enum ResultOutcome: String, Hashable {
    case success
    case failure
}

struct result: View {
    let outcome: ResultOutcome
    @Binding var selectionDate: Date
    @Binding var inputmission: String
    var actualWakeupTime: Date?
    var onChallenge: () -> Void

    var body: some View {
        switch outcome {
        case .success:
            resultsuccess(
                selectionDate: $selectionDate,
                inputmission: $inputmission,
                currentscreen: .constant(.wakeupcomplete),
                actualWakeupTime: actualWakeupTime
            )
        case .failure:
            resultfalse(
                selectionDate: $selectionDate,
                inputmission: $inputmission,
                currentscreen: .constant(.wakeupcomplete),
                actualWakeupTime: actualWakeupTime,
                onChallenge: onChallenge
            )
        }
    }
}

#Preview {
    result(
        outcome: .failure,
        selectionDate: .constant(Date()),
        inputmission: .constant(""),
        actualWakeupTime: Date(),
        onChallenge: {}
    )
}
