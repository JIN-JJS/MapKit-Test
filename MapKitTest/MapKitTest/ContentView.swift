//
//  ContentView.swift
//  MapKitTest
//
//  Created by 전준수 on 3/25/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView(selection: .constant(2),
                content:  {
            LocationSearchView().tabItem { Image(systemName: "magnifyingglass.circle.fill")
                Text("위치 검색") }.tag(1)
            SelectLocationView().tabItem { Image(systemName: "paperplane.circle")
                Text("선택 위치") }.tag(2)
        })
    }
}

#Preview {
    ContentView()
}
