//
//  UpGoodViewModel.swift
//  UpGood
//
//  Created by Aayush Pokharel on 2022-05-31.
//

import SwiftUI

class UpGoodViewModel: ObservableObject {
    @Published var fileUploader = FileUploader()
    @Published var localPathURL: URL?
    @Published var currentPage: CurrentPage = .upload

    @AppStorage(AppStorageStrings.uploadMode) var uploadModeRaw: String = UploadMode.temporary.rawValue
    @AppStorage(AppStorageStrings.expiryOption) var expiryOptionRaw: String = ExpiryOption.oneDay.rawValue

    var uploadMode: UploadMode {
        get { UploadMode(rawValue: uploadModeRaw) ?? .temporary }
        set { uploadModeRaw = newValue.rawValue }
    }

    var expiryOption: ExpiryOption {
        get { ExpiryOption(rawValue: expiryOptionRaw) ?? .oneDay }
        set { expiryOptionRaw = newValue.rawValue }
    }

    enum CurrentPage {
        case upload
        case options
    }

    init() {}

    init(localPathURL: URL? = nil) {
        self.localPathURL = localPathURL
    }

    func startUpload() {
        guard let url = localPathURL else { return }
        Task { @MainActor in
            await fileUploader.upload(
                fileURL: url,
                mode: uploadMode,
                expiry: expiryOption
            )
        }
    }
}

extension UpGoodViewModel {
    static let previewProvider = UpGoodViewModel(
        localPathURL: URL(filePath: "Users/aayushpokharel/Downloads/A29-Templates-master/")
    )
}
