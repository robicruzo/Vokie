//
//  VokieApp.swift
//  Vokie
//
//  Created by Robsen Gelalcha on 10/14/26.
//

import SwiftUI

@main
struct VokieApp: App {
    @State private var store = VocabularyStore()

    var body: some Scene {
        MenuBarExtra("Vokie", systemImage: "character.book.closed") {
            MenuBarView(store: store)
        }
        .menuBarExtraStyle(.window)
    }
}
