//
//  nebostopApp.swift
//  nebostop
//
//  Created by 岡島結南 on 2026/03/01.
//

import SwiftUI
import SwiftData

@main
struct nebostopApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("hasDeclaredWakeupTime") private var hasDeclaredWakeupTime = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    DeclarationReminderManager.shared.requestAuthorization()
                    DeclarationReminderManager.shared.rescheduleReminderIfNeeded(hasDeclared: hasDeclaredWakeupTime)
                }
        }
        .modelContainer(for: MissionData.self)
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                DeclarationReminderManager.shared.rescheduleReminderIfNeeded(hasDeclared: hasDeclaredWakeupTime)
            }
        }
        .onChange(of: hasDeclaredWakeupTime) { newValue in
            DeclarationReminderManager.shared.rescheduleReminderIfNeeded(hasDeclared: newValue)
        }
    }
}
