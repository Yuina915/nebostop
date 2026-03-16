//
//  mypage.swift
//  nebostop
//
//  Created by 岡島結南 on 2026/03/01.
//

import SwiftUI
import PhotosUI
import SwiftData

struct mypage: View {
    struct DayRecord: Identifiable {
        let id = UUID()
        let dateText: String
        let targetText: String
        let diffText: String
        let diffTimeText: String
        let diffIsLate: Bool
    }

    @Query(sort: [SortDescriptor(\MissionData.actualwakeuptime, order: .reverse)])
    private var missiondata: [MissionData]
    @State private var showEdit = false
    @State private var showRecordsModal = false
    @State private var userName = "ユーザーネーム"
    @State private var userImage: UIImage?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 30) {
                        header
                        sectionTitle("過去の起床履歴")
                        if recentRecords.isEmpty {
                            Text("履歴がありません")
                                .font(.subheadline)
                                .foregroundColor(.black.opacity(0.6))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 8)
                        } else {
                            recordsSection
                            Button {
                                showRecordsModal = true
                            } label: {
                                Text("もっと見る")
                                    .font(.subheadline.bold())
                                    .foregroundColor(Color(red: 253/255, green: 149/255, blue: 96/255))
                                    .frame(maxWidth: .infinity)
                            }
                            .padding(.top, 4)
                        }
                        if !reportItems.isEmpty {
                            sectionTitle("投稿")
                            missionCard
                        } else {
                            sectionTitle("投稿")
                            Text("投稿がありません")
                                .font(.subheadline)
                                .foregroundColor(.black.opacity(0.6))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 8)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showEdit = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.title3)
                            .foregroundColor(.black.opacity(0.8))
                    }
                }
            }
            .sheet(isPresented: $showEdit) {
                MyPageEditModal(userName: $userName, userImage: $userImage)
            }
            .sheet(isPresented: $showRecordsModal) {
                WakeupHistoryModal(records: recentRecords)
            }
        }
        .onAppear {
            print("mypage missiondata count:", missiondata.count)
            if let latest = missiondata.first {
                print("mypage latest mission:", latest.mission, "declared:", latest.wakeuptime, "actual:", latest.actualwakeuptime as Any)
            }
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            if let userImage {
                Image(uiImage: userImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.black.opacity(0.15))
                    .frame(width: 150, height: 150)
            }
            Text(userName)
                .font(.title2.bold())
        }
        .padding(.top, 12)
    }

    private var recordsSection: some View {
        VStack(spacing: 10) {
            ForEach(recentRecords.prefix(3)) { record in
                recordRow(record)
            }
        }
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .foregroundColor(.black.opacity(0.8))
            .frame(maxWidth: .infinity, alignment: .center)
            .overlay(alignment: .center) {
                Rectangle()
                    .fill(Color(red: 253/255, green: 149/255, blue: 96/255))
                    .frame(width: 200, height: 2)
                    .offset(y: 15)
            }
    }

    private func recordRow(_ record: DayRecord) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(record.dateText)
                    .font(.caption)
                    .foregroundColor(.black.opacity(0.6))
                HStack(spacing: 10) {
                    HStack(spacing: 4) {
                        Text("目標")
                            .font(.caption)
                            .foregroundColor(.black.opacity(0.6))
                        Text(record.targetText)
                            .font(.subheadline.bold())
                    }
                    HStack(spacing: 4) {
                        Text("差分")
                            .font(.caption)
                            .foregroundColor(.black.opacity(0.6))
                        Text(record.diffTimeText)
                            .font(.subheadline.bold())
                    }
                }
            }
            Spacer()
            Text(record.diffText)
                .font(.title3.bold())
                .foregroundColor(record.diffIsLate ? Color(red: 253/255, green: 149/255, blue: 96/255) : Color(red: 60/255, green: 140/255, blue: 255/255))
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(Color.black.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var recentRecords: [DayRecord] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M/d (E)"

        return missiondata.compactMap { item in
            guard let actual = item.actualwakeuptime else { return nil }
            let declared = item.wakeuptime
            let diffMinutes = minutesSinceMidnight(actual) - minutesSinceMidnight(declared)
            let diffIsLate = diffMinutes > 0
            let sign = diffMinutes >= 0 ? "+" : "-"
            let absMinutes = abs(diffMinutes)
            let diffHour = absMinutes / 60
            let diffMin = absMinutes % 60
            let diffTimeText = String(format: "%02d:%02d", diffHour, diffMin)
            let diffText = "\(sign)\(absMinutes)m"
            return DayRecord(
                dateText: formatter.string(from: declared),
                targetText: timeText(declared),
                diffText: diffText,
                diffTimeText: diffTimeText,
                diffIsLate: diffIsLate
            )
        }
        .prefix(5)
        .map { $0 }
    }

    private func timeText(_ date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened)
    }

    private func minutesSinceMidnight(_ date: Date) -> Int {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
        return (comps.hour ?? 0) * 60 + (comps.minute ?? 0)
    }

    private var missionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ミッションの内容")
                .font(.headline)
                
            if reportItems.isEmpty {
                Text("投稿がまだありません")
                    .font(.subheadline)
                    .foregroundColor(.black.opacity(0.6))
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(reportItems) { item in
                            reportCard(item)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .frame(height: 220)
            }
        }
        .padding(.top, 8)
        .padding(.horizontal, 6)
        .padding(.vertical, 12)
        .background(Color(red: 253/255, green: 149/255, blue: 96/255))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private struct ReportItem: Identifiable {
        let id = UUID()
        let mission: String
        let imageData: Data
        let dateText: String
    }

    private var reportItems: [ReportItem] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M/d (E)"

        return missiondata
            .sorted { (lhs, rhs) in
                let l = lhs.reportCreatedAt ?? .distantPast
                let r = rhs.reportCreatedAt ?? .distantPast
                return l > r
            }
            .compactMap { item in
            guard let data = item.reportImageData,
                  let createdAt = item.reportCreatedAt else {
                return nil
            }
            return ReportItem(
                mission: item.mission,
                imageData: data,
                dateText: formatter.string(from: createdAt)
            )
        }
        .prefix(5)
        .map { $0 }
    }

    @ViewBuilder
    private func reportCard(_ item: ReportItem) -> some View {
        if let uiImage = UIImage(data: item.imageData) {
            VStack(alignment: .leading, spacing: 10) {
                ZStack {
                    Rectangle()
                        .fill(Color.white.opacity(0.12))
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .clipped()
                }
                .frame(height: 140)
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
                .overlay(
                    UnevenRoundedRectangle(
                        cornerRadii: RectangleCornerRadii(
                            topLeading: 0,
                            bottomLeading: 18,
                            bottomTrailing: 18,
                            topTrailing: 0
                        )
                    )
                    .stroke(Color(red: 253/255, green: 149/255, blue: 96/255), lineWidth: 3)
                )
                Text(item.mission)
                    .font(.subheadline.bold())
                    .foregroundColor(.black.opacity(0.8))
                Text(item.dateText)
                    .font(.caption)
                    .foregroundColor(.black.opacity(0.6))
            }
            .padding(12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

#Preview {
    mypage()
}

private struct WakeupHistoryModal: View {
    let records: [mypage.DayRecord]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(records) { record in
                        WakeupHistoryModal.row(record)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
            .navigationTitle("過去の起床履歴")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private static func row(_ record: mypage.DayRecord) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(record.dateText)
                    .font(.caption)
                    .foregroundColor(.black.opacity(0.6))
                HStack(spacing: 10) {
                    HStack(spacing: 4) {
                        Text("目標")
                            .font(.caption)
                            .foregroundColor(.black.opacity(0.6))
                        Text(record.targetText)
                            .font(.subheadline.bold())
                    }
                    HStack(spacing: 4) {
                        Text("差分")
                            .font(.caption)
                            .foregroundColor(.black.opacity(0.6))
                        Text(record.diffTimeText)
                            .font(.subheadline.bold())
                    }
                }
            }
            Spacer()
            Text(record.diffText)
                .font(.title3.bold())
                .foregroundColor(record.diffIsLate ? Color(red: 253/255, green: 149/255, blue: 96/255) : Color(red: 60/255, green: 140/255, blue: 255/255))
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(Color.black.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct MyPageEditModal: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var userName: String
    @Binding var userImage: UIImage?
    @State private var draftName: String = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 36)
                            .fill(Color.white)
                        VStack(spacing: 18) {
                            Text("マイページを編集")
                                .font(.headline)
                                .padding(.top, 10)
                            profileImagePicker
                            Text("ユーザーネーム")
                                .font(.title3.bold())
                            TextField("例", text: $draftName)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 14)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.black.opacity(0.2), lineWidth: 1)
                                )
                                .padding(.horizontal, 24)
                            Spacer()
                        }
                        .padding(.top, 22)
                        .padding(.bottom, 24)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    }
                    .overlay(alignment: .topLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.headline)
                                .foregroundColor(.black.opacity(0.7))
                                .padding(10)
                                .background(Color.black.opacity(0.08))
                                .clipShape(Circle())
                        }
                        .padding(16)
                    }
                    .overlay(alignment: .topTrailing) {
                        Button {
                            let trimmed = draftName.trimmingCharacters(in: .whitespacesAndNewlines)
                            if !trimmed.isEmpty {
                                userName = trimmed
                            }
                            if let selectedImage {
                                userImage = selectedImage
                            }
                            dismiss()
                        } label: {
                            Image(systemName: "arrow.up")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color(red: 253/255, green: 149/255, blue: 96/255))
                                .clipShape(Circle())
                        }
                        .padding(16)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 12)
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    init(userName: Binding<String>, userImage: Binding<UIImage?>) {
        self._userName = userName
        self._userImage = userImage
        self._draftName = State(initialValue: userName.wrappedValue)
        self._selectedImage = State(initialValue: userImage.wrappedValue)
    }

    private var profileImagePicker: some View {
        ZStack {
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                ZStack {
                    Circle()
                        .fill(Color(red: 253/255, green: 149/255, blue: 96/255))
                        .frame(width: 170, height: 170)
                    if let selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 170, height: 170)
                            .clipShape(Circle())
                        Circle()
                            .fill(Color.black.opacity(0.25))
                            .frame(width: 170, height: 170)
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 44, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 44, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    await MainActor.run {
                        selectedImage = uiImage
                    }
                }
            }
        }
    }
}
