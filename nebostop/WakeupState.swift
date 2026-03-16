import Foundation
import Combine

final class WakeupState: ObservableObject {
    struct ResultRecord {
        let declared: Date
        let actual: Date
        let outcome: ResultOutcome
    }

    @Published private(set) var lastRecordedResult: ResultRecord?
    @Published var isResultActive = false

    func record(declared: Date, actual: Date, outcome: ResultOutcome) {
        lastRecordedResult = ResultRecord(declared: declared, actual: actual, outcome: outcome)
    }

    func reset() {
        lastRecordedResult = nil
    }
}
