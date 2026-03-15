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
    @Query(sort: [SortDescriptor(\MissionData.createdAt, order: .reverse)])
    private var missiondata: [MissionData]
    @Query(
        filter: #Predicate<MissionData> { $0.actualwakeuptime == nil },
        sort: [SortDescriptor(\MissionData.createdAt, order: .reverse)]
    )
    private var pendingMissions: [MissionData]
    @Binding var tabSelection: Int
    @Binding var beginingScreen: Screen
    @Binding var selectionDate: Date
    @Binding var inputmission: String
    @Binding var resetToken: UUID
    @State private var actualWakeupTime: Date?
    @State private var path = NavigationPath()
    @AppStorage("hasDeclaredWakeupTime") private var hasDeclaredWakeupTime = false
    @AppStorage("debugSaveMessage") private var debugSaveMessage: String = ""
    @State private var dragOffset: CGFloat = 0
    @State private var isTransitioning = false
    @State private var orangeHeight: CGFloat = 0

    private var pendingMission: MissionData? {
        if let pending = pendingMissions.first {
            return pending
        }
        if hasDeclaredWakeupTime {
            return missiondata.first
        }
        return nil
    }

    private var canPerformWakeup: Bool {
        pendingMission != nil || hasDeclaredWakeupTime
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
                if !canPerformWakeup && path.isEmpty {
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
                            path.append(WakeupRoute.selectmission)
                        }
                    )
                case .selectmission:
                    selectmission(
                        selectionDate: $selectionDate,
                        inputmission: $inputmission,
                        onSelectMission: { mission in
                            inputmission = mission
                            DispatchQueue.main.async {
                                path.append(WakeupRoute.missionconfirm)
                            }
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
            if let latestMission = pendingMission {
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
        if let latestMission = pendingMission {
            selectionDate = latestMission.wakeuptime
            inputmission = latestMission.mission
            latestMission.actualwakeuptime = now
            try? modelcontext.save()
            actualWakeupTime = now
            let isSuccessFromLatest = isSuccessWakeup(actual: now, declared: latestMission.wakeuptime)
            let outcome: ResultOutcome = isSuccessFromLatest ? .success : .failure
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
    }
}

#Preview("Wakeup Disabled") {
    WakeupPreviewWrapper()
}
