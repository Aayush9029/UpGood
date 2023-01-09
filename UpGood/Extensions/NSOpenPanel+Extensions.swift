//
//  NSOpenPanel+Extensions.swift
//  UpGood
//
//  Created by Aayush Pokharel on 2022-04-19.
//

import Cocoa
import UniformTypeIdentifiers

extension NSOpenPanel {
    static func openFile(completion: @escaping (_ result: Result<URL, Error>) -> Void) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [UTType.fileURL, UTType.image]
        panel.canChooseFiles = true
        panel.begin { (result) in
            if result == .OK {
                if let url = panel.urls.first {
                    completion(.success(url))
                }
            } else {
                completion(.failure(
                    NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get file location"])
                ))
            }
        }
    }
}
