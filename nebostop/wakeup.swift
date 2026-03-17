//
//  wakeup.swift
//  nebostop
//
//  Created by 岡島結南 on 2026/03/01.
//

import SwiftUI
import SwiftData
import Combine

struct wakeup: View {
    enum WakeupRoute: Hashable {
        case result(ResultOutcome)
        case selectmission
        case missionconfirm
        case missionreport
    }

    final class WakeupRouter: ObservableObject {
        @Published var path: [WakeupRoute] = []
    }

    @Environment(\.modelContext) private var modelcontext
    @Query(sort: [SortDescriptor(\MissionData.createdAt, order: .reverse)])
    private var missiondata: [MissionData]
    @Query(
        filter: #Predicate<MissionData> { $0.actualwakeuptime == nil },
        sort: [SortDescriptor(\MissionData.createdAt, order: .reverse)]
    )
    private var pendingMissions: [MissionData]
    @Query(
        filter: #Predicate<MissionData> { $0.actualwakeuptime != nil },
        sort: [SortDescriptor(\MissionData.actualwakeuptime, order: .reverse)]
    )
    private var completedMissions: [MissionData]
    @Binding var tabSelection: Int
    @Binding var beginingScreen: Screen
    @Binding var selectionDate: Date
    @Binding var inputmission: String
    @Binding var resetToken: UUID
    @State private var actualWakeupTime: Date?
    @StateObject private var router = WakeupRouter()
    @State private var hasDisplayedFailureResult = false
    @AppStorage("hasDeclaredWakeupTime") private var hasDeclaredWakeupTime = false
    @AppStorage("debugSaveMessage") private var debugSaveMessage: String = ""
    @State private var dragOffset: CGFloat = 0
    @State private var isTransitioning = false
    @State private var orangeHeight: CGFloat = 0
    @EnvironmentObject private var wakeupState: WakeupState

    private var pendingMission: MissionData? {
        let sortedPending = pendingMissions.sorted { lhs, rhs in
            let l = lhs.createdAt ?? lhs.wakeuptime
            let r = rhs.createdAt ?? rhs.wakeuptime
            return l > r
        }
        if let pending = sortedPending.first {
            return pending
        }
        if hasDeclaredWakeupTime {
            let sortedAll = missiondata.sorted { lhs, rhs in
                let l = lhs.createdAt ?? lhs.wakeuptime
                let r = rhs.createdAt ?? rhs.wakeuptime
                return l > r
            }
            return sortedAll.first
        }
        return nil
    }

    private var latestCompletedMission: MissionData? {
        completedMissions.first
    }

    private var canPerformWakeup: Bool {
        pendingMission != nil || hasDeclaredWakeupTime || wakeupState.lastRecordedResult != nil || latestCompletedMission != nil
    }

    var body: some View {
        NavigationStack(path: $router.path){
            ZStack{
                Image("wakeup")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                VStack{
                    ZStack{
                        Image("sun")
                            .resizable()
                            .scaledToFit()
                            .ignoresSafeArea()
                        Text("おはよう")
                            .font(.largeTitle .bold())
                            .multilineTextAlignment(.center)
                            .lineSpacing(20)
                            .frame(maxWidth: 300, alignment: .center)
                            .foregroundStyle(Color(.white))
                    }
                    .offset(y: dragOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                guard canPerformWakeup, !isTransitioning else { return }
                                dragOffset = max(0, value.translation.height)
                                orangeHeight = dragOffset
                            }
                            .onEnded { _ in
                                guard canPerformWakeup, !isTransitioning else {
                                    withAnimation(.spring()) { 
                                        dragOffset = 0
                                        orangeHeight = 0
                                    }
                                    return
                                }
                                if dragOffset > 120 {
                                    Haptics.impact(.medium)
                                    startTransition()
                                } else {
                                    withAnimation(.spring()) { 
                                        dragOffset = 0
                                        orangeHeight = 0
                                    }
                                }
                            }
                    )
                    .disabled(!canPerformWakeup)
                    .opacity(canPerformWakeup ? 1.0 : 0.5)
                    Spacer()
                }
            }
            .overlay {
                GeometryReader { geo in
                    Rectangle()
                        .fill(Color(red: 253/255, green: 149/255, blue: 96/255))
                        .frame(width: geo.size.width, height: max(0, orangeHeight))
                        .position(x: geo.size.width / 2, y: max(0, orangeHeight) / 2)
                        .opacity(orangeHeight > 0 ? 1.0 : 0.0)
                        .allowsHitTesting(false)
                }
            }
            .overlay(alignment: .bottom) {
                if !debugSaveMessage.isEmpty {
                    Text(debugSaveMessage)
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.black.opacity(0.7))
                        .clipShape(Capsule())
                        .padding(.bottom, 12)
                }
            }
            .overlay {
                if !canPerformWakeup {
                    ZStack {
                        Color.black.opacity(0.35)
                            .ignoresSafeArea()
                        Text("宣言タブから起床時間を設定してね")
                            .font(.title3.bold())
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 20)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Capsule())
                    }
                }
            }
            .navigationDestination(for: WakeupRoute.self) { value in
                switch value {
                case .result(let outcome):
                    result(
                        outcome: outcome,
                        selectionDate: $selectionDate,
                        inputmission: $inputmission,
                        actualWakeupTime: actualWakeupTime,
                        onChallenge: {
                            router.path.append(WakeupRoute.selectmission)
                        }
                    )
                    .navigationBarBackButtonHidden(true)
                    .navigationBarHidden(true)
                case .selectmission:
                    selectmission(
                        selectionDate: $selectionDate,
                        inputmission: $inputmission,
                        onSelectMission: { mission in
                            print("selectmission chosen:", mission)
                            inputmission = mission
                            DispatchQueue.main.async {
                                router.path.append(WakeupRoute.missionconfirm)
                            }
                        }
                    )
            case .missionconfirm:
                missionconfirm(
                    selectionDate: $selectionDate,
                    inputmission: $inputmission,
                    onConfirm: {
                        router.path.append(WakeupRoute.missionreport)
                    }
                )
            case .missionreport:
                missionreport(
                    inputmission: $inputmission,
                    onReport: {
                        router.path.append(WakeupRoute.result(.success))
                    }
                )
            }
        }
        }
        .onAppear {
            print("wakeup onAppear. pendingMission:", pendingMission != nil, "hasDeclaredWakeupTime:", hasDeclaredWakeupTime)
            if let latestMission = pendingMission {
                selectionDate = latestMission.wakeuptime
                inputmission = latestMission.mission
            }
            refreshDeclarationState()
        }
        .onChange(of: router.path) { newPath in
            print("wakeup path changed:", newPath)
            wakeupState.isResultActive = newPath.last?.isResultRoute ?? false
        }
        .onChange(of: missiondata.count) { _ in
            refreshDeclarationState()
        }
        .onChange(of: missiondata.first?.actualwakeuptime) { _ in
            refreshDeclarationState()
        }
        .onChange(of: wakeupState.lastRecordedResult?.outcome) { newOutcome in
            if newOutcome != .failure {
                hasDisplayedFailureResult = false
            }
        }
        .onChange(of: resetToken) { _ in
            print("wakeup resetToken changed. path:", router.path)
            guard router.path.isEmpty else { return }
            router.path.removeAll()
            dragOffset = 0
            isTransitioning = false
            orangeHeight = 0
        }
    }

    private func startTransition() {
        isTransitioning = true
        let screenHeight = UIScreen.main.bounds.height
        withAnimation(.easeIn(duration: 0.2)) {
            orangeHeight = screenHeight
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            performWakeup()
            withAnimation(.easeOut(duration: 0.55)) {
                dragOffset = -screenHeight
                orangeHeight = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                isTransitioning = false
                dragOffset = 0
            }
        }
    }

    private func performWakeup() {
        if pendingMission == nil {
            if let last = wakeupState.lastRecordedResult {
                selectionDate = last.declared
                actualWakeupTime = last.actual
                let outcome: ResultOutcome
                if last.outcome == .failure && hasDisplayedFailureResult {
                    outcome = .success
                } else {
                    outcome = last.outcome
                    if outcome == .failure {
                        hasDisplayedFailureResult = true
                    }
                }
                Haptics.notify(outcome == .success ? .success : .warning)
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    router.path.append(WakeupRoute.result(outcome))
                }
                beginingScreen = .start
                return
            }
            if let completed = latestCompletedMission,
               let actual = completed.actualwakeuptime {
                selectionDate = completed.wakeuptime
                actualWakeupTime = actual
                let outcome: ResultOutcome = isSuccessWakeup(actual: actual, declared: completed.wakeuptime) ? .success : .failure
                Haptics.notify(outcome == .success ? .success : .warning)
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    router.path.append(WakeupRoute.result(outcome))
                }
                beginingScreen = .start
                return
            }
        }
        let now = Date()
        actualWakeupTime = now
        guard let latestMission = pendingMission else {
            print("performWakeup called without pending mission despite guard")
            return
        }
        selectionDate = latestMission.wakeuptime
        inputmission = latestMission.mission
        latestMission.actualwakeuptime = now
        try? modelcontext.save()
        actualWakeupTime = now
        let isSuccessFromLatest = isSuccessWakeup(actual: now, declared: latestMission.wakeuptime)
        let outcome: ResultOutcome = isSuccessFromLatest ? .success : .failure
        wakeupState.record(declared: latestMission.wakeuptime, actual: now, outcome: outcome)
        Haptics.notify(outcome == .success ? .success : .warning)
        hasDisplayedFailureResult = (outcome == .failure)
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            router.path.append(WakeupRoute.result(outcome))
        }
        hasDeclaredWakeupTime = false
        WakeupFollowupManager.shared.cancelFollowup()
        beginingScreen = .start
    }

    private func isSuccessWakeup(actual: Date, declared: Date) -> Bool {
        minutesSinceMidnight(actual) <= minutesSinceMidnight(declared)
    }

    private func minutesSinceMidnight(_ date: Date) -> Int {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
        return (comps.hour ?? 0) * 60 + (comps.minute ?? 0)
    }

    private func refreshDeclarationState() {
        if pendingMissions.first != nil {
            hasDeclaredWakeupTime = true
            return
        }
        if hasDeclaredWakeupTime {
            return
        }
        if let latest = missiondata.first, latest.actualwakeuptime == nil {
            hasDeclaredWakeupTime = true
            return
        }
        hasDeclaredWakeupTime = false
    }
}

struct WakeupPreviewWrapper: View {
    init() {
        UserDefaults.standard.set(false, forKey: "hasDeclaredWakeupTime")
    }

    var body: some View {
        wakeup(
            tabSelection: .constant(1),
            beginingScreen: .constant(.start),
            selectionDate: .constant(Date()),
            inputmission: .constant(""),
            resetToken: .constant(UUID())
        )
        .modelContainer(for: MissionData.self, inMemory: true)
        .environmentObject(WakeupState())
    }
}

#Preview("Wakeup Disabled") {
    WakeupPreviewWrapper()
}

private extension wakeup.WakeupRoute {
    var isResultRoute: Bool {
        if case .result = self {
            return true
        }
        return false
    }
}
