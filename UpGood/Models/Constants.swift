//
//  Constants.swift
//  UpGood
//
//  Created by Aayush Pokharel on 2022-05-31.
//

import Foundation

struct Constants {
    static let githubURL = URL(string: "https://github.com/Aayush9029")!
    static let transferURL = URL(string: "https://transfer.sh")!

    // MARK: - TODO

//    static let versionURL = URL(string: ".json")!

    static let storeOptions: [Int] = Array(3 ..< 15)
    static let downloadsOptions: [Int] = [1, 2, 5, 10, 15, 20, 50, 80, 100, 200, 500, 1000]
}

enum AppStorageStrings {
    static let maxDownloads = "com.aayush.opensource.upgood.maxdownload"
    static let maxDays = "com.aayush.opensource.upgood.maxdays"
    static let lastUploadURL = "com.aayush.opensource.upgood.lasturl"
}
