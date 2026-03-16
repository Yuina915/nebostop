//
//  selectmission.swift
//  nebostop
//
//  Created by 岡島結南 on 2026/03/14.
//

import SwiftUI
import SwiftData

struct selectmission: View {
    @Binding var selectionDate: Date
    @Binding var inputmission: String
    var onSelectMission: (String) -> Void
    @Query(sort: [SortDescriptor(\MissionData.createdAt, order: .reverse)])
    private var missiondata: [MissionData]
    @State private var currentStep = 0
    let totalSteps = 3

    var body: some View {
            ZStack{
                Image("whenyouwakeup2")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                VStack{
                    ZStack{
                        Rectangle()
                            .fill(Color.white)
                            .frame(maxWidth: 300, maxHeight: 65)
                            .cornerRadius(30)
                            .overlay(
                            RoundedRectangle(cornerRadius: 30).stroke(Color(red: 149/255, green: 149/255, blue: 149/255), lineWidth: 3)
                            )
                        Text("今日のミッションはこちら！")
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .lineSpacing(20)
                            .frame(maxWidth: 300, alignment: .center)
                    }
                    .padding(.top,140)
                    Spacer()
                }
                GeometryReader { geo in
                    VStack{
                        Spacer()
                        VStack(spacing: 15){
                            if todaysMissions.isEmpty {
                                Text("今日設定されたミッションはありません")
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.black.opacity(0.7))
                            } else {
                                ForEach(todaysMissions.indices, id: \.self) { index in
                                    let mission = todaysMissions[index]
                                    let missionText = mission.mission.trimmingCharacters(in: .whitespacesAndNewlines)
                                    HStack{
                                        Image(systemName: "person.circle")
                                            .font(.system(size: 35, weight: .regular))
                                        ZStack{
                                            Rectangle()
                                                .fill(Color(.white))
                                                .frame(width: geo.size.width * 0.40, height: geo.size.height * 0.05)
                                                .cornerRadius(10)
                                            Text(missionText)
                                                .lineLimit(1)
                                                .font(.subheadline)
                                        }
                                        Button{
                                            Haptics.impact(.light)
                                            inputmission = missionText
                                            onSelectMission(missionText)
                                        }label: {
                                            Text("これにする")
                                                .font(.caption)
                                                .foregroundColor(.white)
                                                .padding(.vertical, 10)
                                                .padding(.horizontal, 10)
                                                .background(Color(red: 253/255, green: 149/255, blue: 96/255))
                                                .cornerRadius(30)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background(Color(red: 217/255, green: 217/255, blue: 217/255))
                        .cornerRadius(15)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .offset(y: geo.size.height * 0.10)
                }
            }
            .overlay {
                ProgressBarOverlay(currentStep: currentStep, totalSteps: totalSteps)
            }
        }
    
    private var todaysMissions: [MissionData] {
        let calendar = Calendar.current
        return missiondata.filter { mission in
            guard let createdAt = mission.createdAt else {
                return false
            }
            let isToday = calendar.isDateInToday(createdAt)
            let hasText = !mission.mission.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            return isToday && hasText
        }
    }

    private struct MissionRowView: View {
        let mission: MissionData
        let missionText: String
        let availableWidth: CGFloat
        let availableHeight: CGFloat
        let onSelect: (String) -> Void

        var body: some View {
            let tileHeight = availableHeight * 0.05
            HStack(spacing: 12){
                if let profileImageData = mission.enteredByProfileImageData,
                   let uiImage = UIImage(data: profileImageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                } else {
                    Image(systemName: mission.enteredByIconName ?? "person.circle")
                        .font(.system(size: 35, weight: .regular))
                }
                ZStack{
                    Rectangle()
                        .fill(Color(.white))
                        .frame(width: availableWidth * 0.40, height: max(tileHeight, 40))
                        .cornerRadius(10)
                    Text(missionText)
                        .lineLimit(1)
                        .font(.subheadline)
                }
                Button{
                    Haptics.impact(.light)
                    onSelect(missionText)
                }label: {
                    Text("これにする")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 10)
                        .background(Color(red: 253/255, green: 149/255, blue: 96/255))
                        .cornerRadius(30)
                }
            }
        }
    }
}
#Preview {
    SelectMissionPreviewWrapper()
}

private struct SelectMissionPreviewWrapper: View {
    var body: some View {
        SelectMissionPreviewContent()
            .modelContainer(for: MissionData.self, inMemory: true)
    }
}

private struct SelectMissionPreviewContent: View {
    @Environment(\.modelContext) private var modelContext
    @State private var seeded = false

    var body: some View {
        selectmission(
            selectionDate: .constant(Calendar.current.date(byAdding: .hour, value: 8, to: Date()) ?? Date()),
            inputmission: .constant(""),
            onSelectMission: { _ in }
        )
        .onAppear {
            guard !seeded else { return }
            seedMissions()
            seeded = true
        }
    }

    private func seedMissions() {
        let samples = [
            ("早朝ジョギングで公園を一周", "person.crop.circle"),
            ("水を2リットル飲む", "drop"),
            ("好きな本を30ページ読む", "book.circle"),
            ("朝ごはんにフルーツを添える", "leaf"),
            ("瞑想を10分行う", "brain.head.profile")
        ]
        for (index, entry) in samples.enumerated() {
            let mission = MissionData(
                wakeuptime: Calendar.current.date(byAdding: .day, value: -index, to: Date()) ?? Date(),
                mission: entry.0,
                createdAt: Date(),
                enteredByIconName: entry.1
            )
            modelContext.insert(mission)
        }
        try? modelContext.save()
    }
}
