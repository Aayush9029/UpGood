//
//  Networking.swift
//  UpGood
//
//  Created by Aayush Pokharel on 2022-05-31.
//

import Combine
import SwiftUI

class FileUploader: NSObject {
    @AppStorage(AppStorageStrings.maxDays) var maxDays: Int = 5
    @AppStorage(AppStorageStrings.maxDownloads) var maxDownloads: Int = 5
    @AppStorage(AppStorageStrings.lastUploadURL) var lastUploadURL: String = ""

    typealias Percentage = Double
    typealias Publisher = AnyPublisher<Percentage, Error>

    private typealias Subject = CurrentValueSubject<Percentage, Error>

    private lazy var urlSession = URLSession(
        configuration: .default,
        delegate: self,
        delegateQueue: .main
    )

    private var subjectsByTaskID = [Int: Subject]()

    func uploadFile(at fileURL: URL) async throws -> (Data, URLResponse) {
        _ = fileURL.absoluteString.replacingOccurrences(of: "file:///", with: "")

        var request = URLRequest(
            url: Constants.transferURL,
            cachePolicy: .reloadIgnoringLocalCacheData
        )

        request.httpMethod = "PUT"
        request.addValue("\(maxDays)", forHTTPHeaderField: "Max-Days")
        request.addValue("\(maxDownloads)", forHTTPHeaderField: "Max-Downloads")

        let (data, urlResponse) = try await urlSession.upload(
            for: request,
            fromFile: fileURL,
            delegate: nil
        )

        return (data, urlResponse)
    }
}

extension FileUploader: URLSessionTaskDelegate {
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64
    ) {
        print("fractionCompleted  : \(Int(Float(totalBytesSent) / Float(totalBytesExpectedToSend) * 100))")
    }
}
