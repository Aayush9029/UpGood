//
//  FileUploader.swift
//  UpGood
//
//  Created by Aayush Pokharel on 2022-05-31.
//

import SwiftUI

class FileUploader: NSObject, ObservableObject {
    @Published var progress: Double = 0.0
    @Published var isUploading: Bool = false
    @Published var resultURL: String?
    @Published var errorMessage: String?

    private lazy var urlSession = URLSession(
        configuration: .default,
        delegate: self,
        delegateQueue: .main
    )

    @MainActor
    func upload(fileURL: URL, mode: UploadMode, expiry: ExpiryOption) async {
        isUploading = true
        progress = 0.0
        resultURL = nil
        errorMessage = nil

        do {
            let fileSize = try FileManager.default.attributesOfItem(
                atPath: fileURL.path
            )[.size] as? Int64 ?? 0

            if fileSize > mode.maxSize {
                let limitMB = mode.maxSize / 1_000_000
                errorMessage = "File too large (limit: \(limitMB) MB)"
                isUploading = false
                return
            }

            let boundary = UUID().uuidString
            let apiURL: URL
            var bodyData = Data()

            switch mode {
            case .temporary:
                apiURL = Constants.litterboxAPI
                bodyData.appendField("reqtype", value: "fileupload", boundary: boundary)
                bodyData.appendField("time", value: expiry.rawValue, boundary: boundary)
            case .permanent:
                apiURL = Constants.catboxAPI
                bodyData.appendField("reqtype", value: "fileupload", boundary: boundary)
            }

            let fileData = try Data(contentsOf: fileURL)
            let fileName = fileURL.lastPathComponent
            let mimeType = mimeTypeFor(fileURL)

            bodyData.append("--\(boundary)\r\n".data(using: .utf8)!)
            bodyData.append("Content-Disposition: form-data; name=\"fileToUpload\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
            bodyData.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
            bodyData.append(fileData)
            bodyData.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

            var request = URLRequest(url: apiURL)
            request.httpMethod = "POST"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

            let (data, response) = try await urlSession.upload(
                for: request,
                from: bodyData
            )

            guard let httpResponse = response as? HTTPURLResponse,
                  (200 ... 299).contains(httpResponse.statusCode) else {
                errorMessage = "Upload failed (server error)"
                isUploading = false
                return
            }

            if let urlString = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
               !urlString.isEmpty {
                resultURL = urlString
                UserDefaults.standard.set(urlString, forKey: AppStorageStrings.lastUploadURL)
            } else {
                errorMessage = "No URL returned from server"
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isUploading = false
    }

    private func mimeTypeFor(_ url: URL) -> String {
        let ext = url.pathExtension.lowercased()
        switch ext {
        case "png": return "image/png"
        case "jpg", "jpeg": return "image/jpeg"
        case "gif": return "image/gif"
        case "webp": return "image/webp"
        case "mp4": return "video/mp4"
        case "mov": return "video/quicktime"
        case "mp3": return "audio/mpeg"
        case "pdf": return "application/pdf"
        case "zip": return "application/zip"
        case "txt": return "text/plain"
        default: return "application/octet-stream"
        }
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
        progress = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
    }
}

extension Data {
    mutating func appendField(_ name: String, value: String, boundary: String) {
        append("--\(boundary)\r\n".data(using: .utf8)!)
        append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
        append("\(value)\r\n".data(using: .utf8)!)
    }
}
