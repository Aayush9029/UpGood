//
//  UpGoodApp.swift
//  UpGood
//
//  Created by Aayush Pokharel on 2023-01-09.
//

import SwiftUI

@main
struct UpGoodApp: App {
    var body: some Scene {
        MenuBarExtra {
            MainView()
                .frame(width: 280)
        } label: {
            Label("UpGood", systemImage: "icloud.and.arrow.up.fill")
        }
        .menuBarExtraStyle(.window)
    }
}
