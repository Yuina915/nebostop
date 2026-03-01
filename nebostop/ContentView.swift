//
//  ContentView.swift
//  nebostop
//
//  Created by 岡島結南 on 2026/03/01.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView{
            start()
                .tabItem {
                    Image(systemName: "megaphone.fill")
                    Text("宣言")
                }
            wakeup()
                .tabItem {
                    Image(systemName: "sun.max.fill")
                    Text("おきたよ")
                }
            group()
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("グループ")
                }
            mypage()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("my page")
                }
            
            
        }
    }
}

#Preview {
    ContentView()
}
