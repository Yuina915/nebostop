//
//  group.swift
//  nebostop
//
//  Created by 岡島結南 on 2026/03/01.
//

import SwiftUI
import UIKit

struct group: View {
    struct GroupRow: Identifiable {
        let id = UUID()
        let name: String
        let members: Int
        let wokeUpCount: Int
        let totalCount: Int
    }

    @State private var groups: [GroupRow] = [
        GroupRow(name: "グループ名", members: 0, wokeUpCount: 0, totalCount: 0),
        GroupRow(name: "グループ名", members: 0, wokeUpCount: 0, totalCount: 0),
        GroupRow(name: "グループ名", members: 0, wokeUpCount: 0, totalCount: 0)
    ]
    @State private var showCreateGroup = false
    @State private var showToast = false
    @State private var toastMessage = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Image("whenyouwakeup2")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                VStack(spacing: 40) {
                    heroArea
                    actionButtons
                    groupList
                }
                .padding(.horizontal, 22)
                .padding(.top, 140)
                .padding(.bottom, 24)
                .overlay {
                    if showToast {
                        ToastOverlay(text: toastMessage)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }

            .sheet(isPresented: $showCreateGroup) {
                GroupCreateModal { newGroupName in
                    groups.append(
                        GroupRow(name: newGroupName, members: 1, wokeUpCount: 0, totalCount: 1)
                    )
                    toastMessage = "\(newGroupName) が作成されました"
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showToast = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showToast = false
                        }
                    }
                }
            }
        }
    }

    private var heroArea: some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 30)
                .stroke(Color(red: 149/255, green: 149/255, blue: 149/255), lineWidth: 3)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.white)
                )
                .frame(height: 65)
                .overlay(
                    Text("グループに参加しよう！")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .lineSpacing(20)
                )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var actionButtons: some View {
        GeometryReader { geo in
            HStack{
                Spacer()
                VStack(spacing: 12) {
                    Button {
                        showCreateGroup = true
                    } label: {
                        Label("グループを作成", systemImage: "plus")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(FilledCapsuleButtonStyle())

                    Button {
                    } label: {
                        Label("招待コード", systemImage: "key.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(OutlinedCapsuleButtonStyle())
                }
                .frame(width: geo.size.width * 0.6)
            }
        }
        .frame(height: 130)
    }

    private var groupList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("現在参加しているグループ")
                .font(.headline)
                .foregroundColor(.black.opacity(0.8))
                .frame(maxWidth: .infinity, alignment: .center)
                .overlay(alignment: .center) {
                    Rectangle()
                        .fill(Color(red: 149/255, green: 149/255, blue: 149/255))
                        .frame(width: 200, height: 2)
                        .offset(y: 15)
                }

            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(groups) { group in
                        GroupRowView(group: group)
                    }
                }
            }
            .frame(maxHeight: 400)
        }
        .padding(.bottom, 50)
    }
}

private struct GroupRowView: View {
    let group: group.GroupRow

    var body: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(Color(red: 253/255, green: 149/255, blue: 96/255))
                .frame(width: 4)
                .cornerRadius(2)

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("\(group.name) (\(group.members)人)")
                        .font(.subheadline.bold())
                    Spacer()
                    Text("\(group.wokeUpCount)/\(group.totalCount) 起床済み")
                        .font(.caption)
                        .foregroundColor(.black.opacity(0.6))
                }
                HStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { _ in
                        Image(systemName: "person.circle")
                            .font(.title3)
                            .foregroundColor(.black.opacity(0.7))
                    }
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.black.opacity(0.4))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 4)
    }
}

private struct FilledCapsuleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.bold())
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color(red: 253/255, green: 149/255, blue: 96/255))
            .clipShape(Capsule())
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

private struct OutlinedCapsuleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.bold())
            .foregroundColor(Color(red: 253/255, green: 149/255, blue: 96/255))
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color.white)
            .overlay(
                Capsule()
                    .stroke(Color(red: 253/255, green: 149/255, blue: 96/255), lineWidth: 2)
            )
            .clipShape(Capsule())
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

#Preview {
    group()
}

private struct GroupCreateModal: View {
    @Environment(\.dismiss) private var dismiss
    @State private var groupName = ""
    @State private var selectedIconIndex = 1
    @State private var icons: [String] = ["🙂", "📜", "😂", "🐔", "🐵", "🔥", "💕", "🎵", "+"]
    @State private var newIcon = ""
    @State private var isEditingCustomIcon = false
    @FocusState private var isEmojiFieldFocused: Bool
    @State private var groupId = GroupCreateModal.makeGroupId()
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastIsError = false
    var onCreate: (String) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                VStack(spacing: 18) {
                    groupPreviewCard
                    nameField
                    iconPicker
                    inviteCodeSection
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, -8)
                .overlay {
                    if showToast {
                        ToastOverlay(
                            text: toastMessage,
                            bottomPadding: 12,
                            backgroundColor: toastIsError ? Color(red: 235/255, green: 87/255, blue: 87/255) : Color(red: 198/255, green: 236/255, blue: 100/255)
                        )
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.headline)
                            .foregroundColor(.black.opacity(0.7))
                            .padding(8)
                            .clipShape(Circle())
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("グループを作成")
                        .font(.headline)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        let name = groupName.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !name.isEmpty else {
                            toastMessage = "グループ名を入力してください"
                            toastIsError = true
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showToast = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    showToast = false
                                }
                            }
                            return
                        }
                        onCreate(name)
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.up")
                            .font(.headline)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(red: 253/255, green: 149/255, blue: 96/255))
                    .clipShape(Circle())
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private var groupPreviewCard: some View {
        VStack(alignment: .leading, spacing: 5) {
            GeometryReader { geo in
                ZStack(alignment: .center) {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.black.opacity(0.08))
                        .frame(width: geo.size.width * 0.8, height: geo.size.height * 0.7)
                        .overlay(
                            VStack(spacing: 8) {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 60, height: 60)
                                    .overlay(
                                        Group {
                                            if isEditingCustomIcon {
                                                TextField("", text: $newIcon)
                                                    .font(.largeTitle)
                                                    .multilineTextAlignment(.center)
                                                    .focused($isEmojiFieldFocused)
                                                    .onChange(of: newIcon) { _, value in
                                                        newIcon = String(value.prefix(1))
                                                    }
                                                    .onSubmit {
                                                        commitCustomIcon()
                                                    }
                                            } else {
                                                Text(icons[safe: selectedIconIndex] ?? "🙂")
                                                    .font(.largeTitle)
                                            }
                                        }
                                    )
                                Text(groupName.isEmpty ? "グループ名" : groupName)
                                    .font(.title)
                            }
                        )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .frame(height: UIScreen.main.bounds.height * 0.3)
        }
    }

    private var nameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("グループ名")
                .font(.headline)
            TextField("例", text: $groupName)
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
                .background(Color.black.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var iconPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("アイコン")
                .font(.headline)
            LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 12), count: 5), spacing: 12) {
                ForEach(icons.indices, id: \.self) { index in
                    Button {
                        if icons[index] == "+" {
                            newIcon = ""
                            isEditingCustomIcon = true
                            isEmojiFieldFocused = true
                        } else {
                            isEditingCustomIcon = false
                            selectedIconIndex = index
                            newIcon = icons[index]
                        }
                    } label: {
                        Text(icons[index])
                            .font(.title3)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(index == selectedIconIndex ? Color(red: 253/255, green: 149/255, blue: 96/255).opacity(0.25) : Color.black.opacity(0.08))
                            )
                            .overlay(
                                Circle()
                                    .stroke(index == selectedIconIndex ? Color(red: 253/255, green: 149/255, blue: 96/255) : Color.clear, lineWidth: 2)
                            )
                    }
                }
            }
        }
    }

    private func commitCustomIcon() {
        guard !newIcon.isEmpty else {
            isEditingCustomIcon = false
            return
        }
        if let plusIndex = icons.firstIndex(of: "+") {
            icons.insert(newIcon, at: plusIndex)
            selectedIconIndex = plusIndex
        } else {
            icons.append(newIcon)
            selectedIconIndex = icons.count - 1
        }
        isEditingCustomIcon = false
    }

    private var inviteCodeSection: some View {
        VStack(spacing: 8) {
            Text("招待コード")
                .font(.headline)
            HStack(spacing: 30) {
                Text(groupId)
                    .font(.title)
                    .foregroundColor(.black)
                Button {
                    UIPasteboard.general.string = groupId
                    toastMessage = "招待コードをコピーしました"
                    toastIsError = false
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showToast = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showToast = false
                        }
                    }
                } label: {
                    Image(systemName: "doc.on.doc")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color(red: 253/255, green: 149/255, blue: 96/255))
                        .clipShape(Circle())
                }
            }
        }
        .padding(.vertical, 6)
    }

    private static func makeGroupId(length: Int = 5) -> String {
        let chars = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        var result = ""
        result.reserveCapacity(length)
        for _ in 0..<length {
            if let c = chars.randomElement() {
                result.append(c)
            }
        }
        return result
    }
}

private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
