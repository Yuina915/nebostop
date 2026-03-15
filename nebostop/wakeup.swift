//
//  wakeup.swift
//  nebostop
//
//  Created by 岡島結南 on 2026/03/01.
//

import SwiftUI
import SwiftData

struct wakeup: View {
    enum WakeupRoute: Hashable {
        case result(ResultOutcome)
        case selectmission
        case missionconfirm
        case missionreport
    }

    @Environment(\.modelContext) private var modelcontext
    @Query(sort: [SortDescriptor(\MissionData.wakeuptime, order: .reverse)])
    private var missiondata: [MissionData]
    @Binding var tabSelection: Int
    @Binding var beginingScreen: Screen
    @Binding var selectionDate: Date
    @Binding var inputmission: String
    @Binding var resetToken: UUID
    @State private var actualWakeupTime: Date?
    @State private var path = NavigationPath()
    @AppStorage("hasDeclaredWakeupTime") private var hasDeclaredWakeupTime = false
    @State private var dragOffset: CGFloat = 0
    @State private var isTransitioning = false
    @State private var orangeHeight: CGFloat = 0

    private var canPerformWakeup: Bool {
        hasDeclaredWakeupTime || missiondata.first != nil
    }

    var body: some View {
        NavigationStack(path: $path){
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
            .navigationDestination(for: WakeupRoute.self) { value in
                switch value {
                case .result(let outcome):
                    result(
                        outcome: outcome,
                        selectionDate: $selectionDate,
                        inputmission: $inputmission,
                        actualWakeupTime: actualWakeupTime,
                        onChallenge: {
                            path.append(WakeupRoute.selectmission)
                        }
                    )
                case .selectmission:
                    selectmission(
                        selectionDate: $selectionDate,
                        inputmission: $inputmission,
                        onSelectMission: { mission in
                            inputmission = mission
                            path.append(WakeupRoute.missionconfirm)
                        }
                    )
            case .missionconfirm:
                missionconfirm(
                    selectionDate: $selectionDate,
                    inputmission: $inputmission,
                    onConfirm: {
                        path.append(WakeupRoute.missionreport)
                    }
                )
            case .missionreport:
                missionreport(
                    inputmission: $inputmission,
                    onReport: {
                        path.append(WakeupRoute.result(.success))
                    }
                )
            }
        }
        }
        .onAppear {
            if let latestMission = missiondata.first {
                selectionDate = latestMission.wakeuptime
                inputmission = latestMission.mission
            }
            refreshDeclarationState()
        }
        .onChange(of: missiondata.count) { _ in
            refreshDeclarationState()
        }
        .onChange(of: missiondata.first?.actualwakeuptime) { _ in
            refreshDeclarationState()
        }
        .onChange(of: resetToken) { _ in
            path = NavigationPath()
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
        let now = Date()
        actualWakeupTime = now
        if let latestMission = missiondata.first {
            selectionDate = latestMission.wakeuptime
            inputmission = latestMission.mission
            let outcome: ResultOutcome
            if latestMission.actualwakeuptime == nil {
                latestMission.actualwakeuptime = now
                try? modelcontext.save()
                actualWakeupTime = now
                let isSuccessFromLatest = isSuccessWakeup(actual: now, declared: latestMission.wakeuptime)
                outcome = isSuccessFromLatest ? .success : .failure
            } else {
                actualWakeupTime = latestMission.actualwakeuptime
                if let actual = latestMission.actualwakeuptime {
                    let isSuccessFromLatest = isSuccessWakeup(actual: actual, declared: latestMission.wakeuptime)
                    outcome = isSuccessFromLatest ? .success : .failure
                } else {
                    outcome = .failure
                }
            }
            Haptics.notify(outcome == .success ? .success : .warning)
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                path.append(WakeupRoute.result(outcome))
            }
            hasDeclaredWakeupTime = false
        } else {
            let isSuccess = isSuccessWakeup(actual: now, declared: selectionDate)
            let outcome: ResultOutcome = isSuccess ? .success : .failure
            Haptics.notify(isSuccess ? .success : .warning)
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                path.append(WakeupRoute.result(outcome))
            }
            hasDeclaredWakeupTime = false
        }
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
        if let latestMission = missiondata.first {
            hasDeclaredWakeupTime = latestMission.actualwakeuptime == nil
        } else {
            hasDeclaredWakeupTime = false
        }
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
    }
}

#Preview("Wakeup Disabled") {
    WakeupPreviewWrapper()
}
