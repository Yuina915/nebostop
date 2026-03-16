import SwiftUI
import Combine

final class ToastManager: ObservableObject {
    @Published var text: String = ""
    @Published var isVisible = false

    private var hideWorkItem: DispatchWorkItem?

    func show(_ text: String, duration: TimeInterval = 2.6) {
        hideWorkItem?.cancel()
        self.text = text
        withAnimation(.easeInOut(duration: 0.25)) {
            isVisible = true
        }
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            withAnimation(.easeInOut(duration: 0.25)) {
                self.isVisible = false
            }
        }
        hideWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: workItem)
    }
}
