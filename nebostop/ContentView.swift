//
//  ContentView.swift
//  nebostop
//
//  Created by 岡島結南 on 2026/03/01.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var currentscreen: Screen = .start
    @State private var selectionDate: Date = Date()
    @State private var inputmission: String = ""
    @State private var wakeupResetToken = UUID()
    var body: some View {
        TabView(selection: $selectedTab){
            begining(
                currentscreen: $currentscreen,
                selectionDate: $selectionDate,
                inputmission: $inputmission,
                wakeupResetToken: $wakeupResetToken
            )
                .tabItem {
                    Image(systemName: "megaphone.fill")
                    Text("宣言")
                }
                .tag(0)
            wakeup(
                tabSelection: $selectedTab,
                beginingScreen: $currentscreen,
                selectionDate: $selectionDate,
                inputmission: $inputmission,
                resetToken: $wakeupResetToken
            )
                .tabItem {
                    Image(systemName: "sun.max.fill")
                    Text("おきたよ")
                }
                .tag(1)
            group()
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("グループ")
                }
                .tag(2)
            mypage()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("my page")
                }
                .tag(3)
            
            
        }
    }
}

#Preview {
    ContentView()
}
