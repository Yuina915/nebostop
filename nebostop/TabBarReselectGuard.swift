import SwiftUI
import UIKit

/// Inserts a helper view controller into the current tab hierarchy and
/// becomes the `UITabBarController` delegate so we can override the default
/// reselect behavior that pops the active navigation stack.
struct TabBarReselectGuard: UIViewControllerRepresentable {
    @EnvironmentObject private var wakeupState: WakeupState

    func makeUIViewController(context: Context) -> UIViewController {
        context.coordinator.host
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        context.coordinator.wakeupState = wakeupState
        if let tabBarController = uiViewController.tabBarController {
            tabBarController.delegate = context.coordinator
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator: NSObject, UITabBarControllerDelegate {
        fileprivate let host = UIViewController()
        weak var wakeupState: WakeupState?
        private let wakeupTabTitle = "おきたよ"

        func tabBarController(
            _ tabBarController: UITabBarController,
            shouldSelect viewController: UIViewController
        ) -> Bool {
            guard wakeupState?.isResultActive == true else {
                return true
            }

            let isSameTab = tabBarController.selectedViewController === viewController
            let isWakeupTab = viewController.tabBarItem.title == wakeupTabTitle

            if isSameTab && isWakeupTab {
                return false
            }
            return true
        }
    }
}
