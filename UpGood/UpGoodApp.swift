//
//  UpGoodApp.swift
//  UpGood
//
//  Created by Aayush Pokharel on 2023-01-09.
//

import SwiftUI

@main
struct UpGoodApp: App {
    @AppStorage(AppStorageStrings.showMenuBarExtra) private var showMenuBarExtra = true

    var body: some Scene {
        WindowGroup {
            MainView()
                .background(.black)
                .frame(width: 280, height: 360)
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)

        MenuBarExtra(isInserted: $showMenuBarExtra) {
            MainView()
                .frame(width: 280, height: 360)
        } label: {
            Label("UpGood", systemImage: "icloud.and.arrow.up.fill")
        }
        .menuBarExtraStyle(.window)

        Settings {
            Text("Settings")
        }
    }
}
