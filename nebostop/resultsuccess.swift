//
//  wakeupcomplete.swift
//  nebostop
//
//  Created by 岡島結南 on 2026/03/02.
//

import SwiftUI
import SwiftData

struct resultsuccess: View {
    @Binding var selectionDate: Date
    @Binding var inputmission: String
    @Binding var currentscreen: Screen
    var actualWakeupTime: Date?
    @Query(sort: [SortDescriptor(\MissionData.reportCreatedAt, order: .reverse)])
    private var missiondata: [MissionData]
    @State private var isEditingMission = false
    @State private var editingMissionText = ""

    private var displayedWakeupTimeText: String {
        selectionDate.formatted(date: .omitted, time: .shortened)
    }
    private var targetTimeText: String {
        selectionDate.formatted(date: .omitted, time: .shortened)
    }
    private var actualTimeText: String {
        guard let actual = actualWakeupTime else {
            return "--:--"
        }
        return actual.formatted(date: .omitted, time: .shortened)
    }
    private var diffTimeText: String {
        guard let actual = actualWakeupTime else {
            return "--:--"
        }
        let diffMinutes = minutesSinceMidnight(actual) - minutesSinceMidnight(selectionDate)
        let sign = diffMinutes >= 0 ? "+" : "-"
        let absMinutes = abs(diffMinutes)
        let hours = absMinutes / 60
        let minutes = absMinutes % 60
        return String(format: "%@%02d:%02d", sign, hours, minutes)
    }
    private var resultMessage: String {
        guard let actual = actualWakeupTime else {
            return "起床時刻を記録できませんでした"
        }
        let actualMinutes = minutesSinceMidnight(actual)
        let declaredMinutes = minutesSinceMidnight(selectionDate)
        if actualMinutes <= declaredMinutes {
            return "起床成功！"
        } else {
            return "起床失敗"
        }
    }
    private var resultTitle: String {
        guard let actual = actualWakeupTime else {
            return "おめでとう！"
        }
        let actualMinutes = minutesSinceMidnight(actual)
        let declaredMinutes = minutesSinceMidnight(selectionDate)
        if actualMinutes <= declaredMinutes {
            return "おめでとう！"
        } else {
            return "ざんねん…"
        }
    }
    private struct TodayReport: Identifiable {
        let id = UUID()
        let mission: String
        let imageData: Data
    }

    private var todayReports: [TodayReport] {
        let calendar = Calendar.current
        return missiondata.compactMap { item in
            guard let createdAt = item.reportCreatedAt,
                  calendar.isDateInToday(createdAt),
                  let data = item.reportImageData else {
                return nil
            }
            return TodayReport(mission: item.mission, imageData: data)
        }
    }
    var body: some View {
        ZStack{
            Image("resultsuccess")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            VStack{
                VStack(alignment: .leading, spacing: 10){
                    Text(resultTitle)
                        .font(.title2)
                        .frame(maxWidth: 250, alignment: .topLeading)
                    Text(resultMessage)
                        .font(.largeTitle .bold())
                        .frame(maxWidth: 250, alignment: .trailing)
                }
                .padding(.top, 110)
                HStack{
                    ZStack{
                            Rectangle()
                                .fill(Color(red: 254/255, green: 213/255, blue: 61/255))
                                .frame(maxWidth: 200,maxHeight: 100)
                                .opacity(0.2)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(red: 254/255, green: 213/255, blue: 61/255), lineWidth: 1.5)
                                )
                                .padding(35)
                        VStack{
                            Text("あなたの記録")
                                .padding(2)
                            HStack(spacing:50){
                                VStack{
                                    Text("目標")
                                    Text(targetTimeText)
                                }
                                VStack{
                                    Text("差分")
                                    Text(diffTimeText)
                                }
                            }
                        }
                    }
                    Spacer()
                }
                if !todayReports.isEmpty {
                    GeometryReader { geo in
                        let pickerWidth = UIScreen.main.bounds.width * 0.8
                        let pickerHeight = geo.size.height * 0.35
                        let noteHeight = geo.size.height * 0.1
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 12) {
                                ForEach(todayReports) { report in
                                    reportCard(
                                        mission: report.mission,
                                        imageData: report.imageData,
                                        width: pickerWidth,
                                        imageHeight: pickerHeight,
                                        noteHeight: noteHeight
                                    )
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .padding(.horizontal, 35)
                }
                Spacer()
            }
            
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    private func minutesSinceMidnight(_ date: Date) -> Int {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
        return (comps.hour ?? 0) * 60 + (comps.minute ?? 0)
    }

    @ViewBuilder
    private func reportCard(mission: String, imageData: Data, width: CGFloat, imageHeight: CGFloat, noteHeight: CGFloat) -> some View {
        if let uiImage = UIImage(data: imageData) {
            VStack(spacing: 0) {
                ZStack {
                    Rectangle()
                        .fill(Color(red: 253/255, green: 149/255, blue: 96/255))
                        .frame(width: width, height: noteHeight)
                        .clipShape(
                            UnevenRoundedRectangle(
                                cornerRadii: RectangleCornerRadii(
                                    topLeading: 18,
                                    bottomLeading: 0,
                                    bottomTrailing: 0,
                                    topTrailing: 18
                                )
                            )
                        )
                    Text(mission)
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .padding(.horizontal, 12)
                }
                ZStack {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: width, height: imageHeight)
                        .clipped()
                        .clipShape(
                            UnevenRoundedRectangle(
                                cornerRadii: RectangleCornerRadii(
                                    topLeading: 0,
                                    bottomLeading: 18,
                                    bottomTrailing: 18,
                                    topTrailing: 0
                                )
                            )
                        )
                }
            }
        }
    }
}

#Preview {
    resultsuccess(
        selectionDate: .constant(Date()),
        inputmission: .constant(""),
        currentscreen: .constant(.wakeupcomplete),
        actualWakeupTime: Date()
    )
}
