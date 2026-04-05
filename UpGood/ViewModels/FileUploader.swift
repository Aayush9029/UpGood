//
//  FileUploader.swift
//  UpGood
//

import Foundation
import IdentifiedCollections
import Sharing

// MARK: - Upload Item

struct UploadItem: Identifiable, Equatable {
    let id: UUID
    let fileURL: URL
    var fileName: String { fileURL.lastPathComponent }
    var progress: Double = 0
    var state: State = .uploading
    var resultURL: String?
    var errorMessage: String?

    enum State: Equatable {
        case uploading, completed, failed
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id && lhs.progress == rhs.progress && lhs.state == rhs.state
    }
}

#if DEBUG
extension UploadItem {
    static let previewUploading = UploadItem(id: UUID(), fileURL: URL(filePath: "/tmp/photo.png"), progress: 0.6)
    static let previewCompleted = UploadItem(id: UUID(), fileURL: URL(filePath: "/tmp/photo.png"), state: .completed, resultURL: "https://litter.catbox.moe/abc123.png")
    static let previewFailed = UploadItem(id: UUID(), fileURL: URL(filePath: "/tmp/photo.png"), state: .failed, errorMessage: "Too large")
}
#endif

// MARK: - Uploader

@Observable
@MainActor
final class Uploader {
    var items: IdentifiedArrayOf<UploadItem> = []

    @ObservationIgnored @Shared(.uploadMode) var modeRaw
    @ObservationIgnored @Shared(.expiryOption) var expiryRaw
    @ObservationIgnored @Shared(.uploadHistory) var history

    var mode: UploadMode {
        get { UploadMode(rawValue: modeRaw) ?? .temporary }
        set { $modeRaw.withLock { $0 = newValue.rawValue } }
    }

    var expiry: ExpiryOption {
        get { ExpiryOption(rawValue: expiryRaw) ?? .oneDay }
        set { $expiryRaw.withLock { $0 = newValue.rawValue } }
    }

    func upload(_ urls: [URL]) {
        for url in urls {
            let isDir = (try? url.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory ?? false
            guard !isDir else { continue }
            startUpload(url)
        }
    }

    // MARK: - Private

    private func startUpload(_ fileURL: URL) {
        let item = UploadItem(id: UUID(), fileURL: fileURL)
        let itemID = item.id
        items.append(item)

        let mode = self.mode
        let expiry = self.expiry

        Task {
            do {
                let attrs = try FileManager.default.attributesOfItem(atPath: fileURL.path)
                let fileSize = attrs[.size] as? Int64 ?? 0

                guard fileSize <= mode.maxBytes else {
                    items[id: itemID]?.state = .failed
                    items[id: itemID]?.errorMessage = "Too large (limit: \(mode.maxBytes / 1_000_000) MB)"
                    return
                }

                let boundary = UUID().uuidString
                let bodyFile = try buildMultipartBody(fileURL: fileURL, mode: mode, expiry: expiry, boundary: boundary)

                var request = URLRequest(url: mode.apiURL)
                request.httpMethod = "POST"
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

                let delegate = ProgressDelegate { [weak self] frac in
                    Task { @MainActor in self?.items[id: itemID]?.progress = frac }
                }

                let session = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
                let (data, response) = try await session.upload(for: request, fromFile: bodyFile)
                try? FileManager.default.removeItem(at: bodyFile)

                guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode),
                      let urlString = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
                      !urlString.isEmpty
                else {
                    items[id: itemID]?.state = .failed
                    items[id: itemID]?.errorMessage = "Upload failed"
                    return
                }

                items[id: itemID]?.state = .completed
                items[id: itemID]?.resultURL = urlString
                items[id: itemID]?.progress = 1

                let record = UploadRecord(
                    id: itemID,
                    fileName: fileURL.lastPathComponent,
                    url: urlString,
                    mode: mode,
                    expiry: mode == .temporary ? expiry : nil,
                    uploadedAt: Date()
                )
                $history.withLock { $0.insert(record, at: 0) }

            } catch {
                items[id: itemID]?.state = .failed
                items[id: itemID]?.errorMessage = error.localizedDescription
            }
        }
    }

    private func buildMultipartBody(fileURL: URL, mode: UploadMode, expiry: ExpiryOption, boundary: String) throws -> URL {
        let tempURL = FileManager.default.temporaryDirectory.appending(component: UUID().uuidString)
        FileManager.default.createFile(atPath: tempURL.path, contents: nil)
        let handle = try FileHandle(forWritingTo: tempURL)

        func field(_ name: String, _ value: String) {
            handle.write("--\(boundary)\r\nContent-Disposition: form-data; name=\"\(name)\"\r\n\r\n\(value)\r\n".data(using: .utf8)!)
        }

        field("reqtype", "fileupload")
        if mode == .temporary { field("time", expiry.rawValue) }

        let mime = Self.mimeType(for: fileURL.pathExtension)
        handle.write("--\(boundary)\r\nContent-Disposition: form-data; name=\"fileToUpload\"; filename=\"\(fileURL.lastPathComponent)\"\r\nContent-Type: \(mime)\r\n\r\n".data(using: .utf8)!)

        let reader = try FileHandle(forReadingFrom: fileURL)
        while true {
            let chunk = reader.readData(ofLength: 1_048_576)
            if chunk.isEmpty { break }
            handle.write(chunk)
        }
        reader.closeFile()

        handle.write("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        handle.closeFile()
        return tempURL
    }

    private static func mimeType(for ext: String) -> String {
        switch ext.lowercased() {
        case "png": "image/png"
        case "jpg", "jpeg": "image/jpeg"
        case "gif": "image/gif"
        case "webp": "image/webp"
        case "mp4": "video/mp4"
        case "mov": "video/quicktime"
        case "mp3": "audio/mpeg"
        case "pdf": "application/pdf"
        case "zip": "application/zip"
        case "txt": "text/plain"
        default: "application/octet-stream"
        }
    }
}

// MARK: - Progress Delegate

private final class ProgressDelegate: NSObject, URLSessionTaskDelegate {
    let onProgress: @Sendable (Double) -> Void

    init(onProgress: @escaping @Sendable (Double) -> Void) {
        self.onProgress = onProgress
    }

    func urlSession(
        _ session: URLSession, task: URLSessionTask,
        didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64
    ) {
        onProgress(Double(totalBytesSent) / Double(totalBytesExpectedToSend))
    }
}
