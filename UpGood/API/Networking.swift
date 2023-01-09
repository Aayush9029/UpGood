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
        let uploadURL = fileURL.absoluteString.replacingOccurrences(of: "file:///", with: "")
        
        var request = URLRequest(
            url: Constants.transferURL,
            cachePolicy: .reloadIgnoringLocalCacheData
        )

        request.httpMethod = "POST"
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

import SwiftUI

class NetworkManager: NSObject {
    static let shared = NetworkManager()
    
    override private init() {}
    
    func uploadZipFile(
        zipFileURL: URL) async throws -> (Data, URLResponse)
    {
        let name: String = zipFileURL.deletingPathExtension().lastPathComponent
        let fileName: String = zipFileURL.lastPathComponent
            
        let zipFileData: Data?
            
        do {
            zipFileData = try Data(contentsOf: zipFileURL)
        } catch {
            throw error
        }
            
        let uploadApiUrl: URL? = URL(string: "https://someapi.com/upload")
            
        // Generate a unique boundary string using a UUID.
        let uniqueBoundary = UUID().uuidString
            
        var bodyData = Data()
            
        // Add the multipart/form-data raw http body data.
        bodyData.append("\r\n--\(uniqueBoundary)\r\n".data(using: .utf8)!)
        bodyData.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        bodyData.append("Content-Type: application/zip\r\n\r\n".data(using: .utf8)!)
            
        // Add the zip file data to the raw http body data.
        bodyData.append(zipFileData!)
            
        // End the multipart/form-data raw http body data.
        bodyData.append("\r\n--\(uniqueBoundary)--\r\n".data(using: .utf8)!)
            
        let urlSessionConfiguration = URLSessionConfiguration.default
            
        let urlSession
            = URLSession(
                configuration: urlSessionConfiguration,
                delegate: self,
                delegateQueue: nil
            )
            
        var urlRequest = URLRequest(url: uploadApiUrl!)
            
        // Set Content-Type Header to multipart/form-data with the unique boundary.
        urlRequest.setValue("multipart/form-data; boundary=\(uniqueBoundary)", forHTTPHeaderField: "Content-Type")
            
        urlRequest.httpMethod = "POST"
            
        let (data, urlResponse) = try await urlSession.upload(
            for: urlRequest,
            from: bodyData,
            delegate: nil
        )
            
        return (data, urlResponse)
    }
}

extension NetworkManager: URLSessionTaskDelegate {
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
