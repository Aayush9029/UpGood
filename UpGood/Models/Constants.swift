//
//  Constants.swift
//  UpGood
//
//  Created by Aayush Pokharel on 2022-05-31.
//

import Foundation

struct Constants {
    static let githubURL = URL(string: "https://github.com/Aayush9029/UpGood")!
    static let litterboxURL = URL(string: "https://litterbox.catbox.moe")!
    static let catboxURL = URL(string: "https://catbox.moe")!

    static let litterboxAPI = URL(string: "https://litterbox.catbox.moe/resources/internals/api.php")!
    static let catboxAPI = URL(string: "https://catbox.moe/user/api.php")!

    static let litterboxMaxSize: Int64 = 1_000_000_000 // 1 GB
    static let catboxMaxSize: Int64 = 200_000_000 // 200 MB
}

enum ExpiryOption: String, CaseIterable, Identifiable {
    case oneHour = "1h"
    case twelveHours = "12h"
    case oneDay = "24h"
    case threeDays = "72h"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .oneHour: return "1 Hour"
        case .twelveHours: return "12 Hours"
        case .oneDay: return "1 Day"
        case .threeDays: return "3 Days"
        }
    }
}

enum UploadMode: String, CaseIterable, Identifiable {
    case temporary
    case permanent

    var id: String { rawValue }

    var label: String {
        switch self {
        case .temporary: return "Temporary"
        case .permanent: return "Permanent"
        }
    }

    var subtitle: String {
        switch self {
        case .temporary: return "Up to 1 GB via Litterbox"
        case .permanent: return "Up to 200 MB via Catbox"
        }
    }

    var maxSize: Int64 {
        switch self {
        case .temporary: return Constants.litterboxMaxSize
        case .permanent: return Constants.catboxMaxSize
        }
    }
}

enum AppStorageStrings {
    static let uploadMode = "com.aayush.opensource.upgood.uploadmode"
    static let expiryOption = "com.aayush.opensource.upgood.expiry"
    static let lastUploadURL = "com.aayush.opensource.upgood.lasturl"
    static let showMenuBarExtra = "showMenuBarExtra"
}
