//
//  UpGoodViewModel.swift
//  UpGood
//
//  Created by Aayush Pokharel on 2022-05-31.
//

import SwiftUI

class UpGoodViewModel: ObservableObject {
    var fileUploader: FileUploader = .init()

    @Published var localPathURL: URL = Constants.transferURL
    @Published var currentPage: CurrentPage = .upload

    @AppStorage(AppStorageStrings.maxDays) var maxDays: Int = 5
    @AppStorage(AppStorageStrings.maxDownloads) var maxDownloads: Int = 5
    @AppStorage(AppStorageStrings.lastUploadURL) var lastUploadURL: String = ""

    enum CurrentPage {
        case upload
        case settings
    }
}
