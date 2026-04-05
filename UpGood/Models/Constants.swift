//
//  Constants.swift
//  UpGood
//

import CasePaths
import Foundation
import IdentifiedCollections
import Sharing

// MARK: - API Endpoints

enum API {
    static let litterbox = URL(string: "https://litterbox.catbox.moe/resources/internals/api.php")!
    static let catbox = URL(string: "https://catbox.moe/user/api.php")!
}

enum Links {
    static let github = URL(string: "https://github.com/Aayush9029/UpGood")!
    static let litterbox = URL(string: "https://litterbox.catbox.moe")!
    static let catbox = URL(string: "https://catbox.moe")!
}

// MARK: - Upload Mode

@CasePathable
enum UploadMode: String, CaseIterable, Identifiable, Codable, Sendable {
    case temporary
    case permanent

    var id: String { rawValue }

    var label: String {
        switch self {
        case .temporary: "Temporary"
        case .permanent: "Permanent"
        }
    }

    var subtitle: String {
        switch self {
        case .temporary: "Up to 1 GB via Litterbox"
        case .permanent: "Up to 200 MB via Catbox"
        }
    }

    var maxBytes: Int64 {
        switch self {
        case .temporary: 1_000_000_000
        case .permanent: 200_000_000
        }
    }

    var serviceURL: URL {
        switch self {
        case .temporary: Links.litterbox
        case .permanent: Links.catbox
        }
    }

    var apiURL: URL {
        switch self {
        case .temporary: API.litterbox
        case .permanent: API.catbox
        }
    }
}

// MARK: - Expiry Option

@CasePathable
enum ExpiryOption: String, CaseIterable, Identifiable, Codable, Sendable {
    case oneHour = "1h"
    case twelveHours = "12h"
    case oneDay = "24h"
    case threeDays = "72h"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .oneHour: "1 Hour"
        case .twelveHours: "12 Hours"
        case .oneDay: "1 Day"
        case .threeDays: "3 Days"
        }
    }

    var timeInterval: TimeInterval {
        switch self {
        case .oneHour: 3600
        case .twelveHours: 43200
        case .oneDay: 86400
        case .threeDays: 259200
        }
    }
}

// MARK: - Upload Record (persisted history)

struct UploadRecord: Codable, Identifiable, Equatable, Sendable {
    let id: UUID
    let fileName: String
    let url: String
    let mode: UploadMode
    let expiry: ExpiryOption?
    let uploadedAt: Date

    var expiresAt: Date? {
        guard let expiry else { return nil }
        return uploadedAt.addingTimeInterval(expiry.timeInterval)
    }

    var isExpired: Bool {
        guard let expiresAt else { return false }
        return Date() > expiresAt
    }
}

// MARK: - Shared Keys

extension SharedKey where Self == AppStorageKey<String>.Default {
    static var uploadMode: Self {
        Self[.appStorage("uploadMode"), default: UploadMode.temporary.rawValue]
    }
    static var expiryOption: Self {
        Self[.appStorage("expiryOption"), default: ExpiryOption.oneDay.rawValue]
    }
}

extension SharedKey where Self == FileStorageKey<IdentifiedArrayOf<UploadRecord>>.Default {
    static var uploadHistory: Self {
        Self[
            .fileStorage(.applicationSupportDirectory.appending(component: "upload-history.json")),
            default: [],
        ]
    }
}
