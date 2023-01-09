//
//  DropDelegate.swift
//  UpGood
//
//  Created by Aayush Pokharel on 2022-05-31.
//

import SwiftUI
import UniformTypeIdentifiers

struct UrlsDropDelegate: DropDelegate {
    @Binding var localPathURL: URL?

    func performDrop(info: DropInfo) -> Bool {
        guard info.hasItemsConforming(to: [UTType.url, UTType.fileURL, UTType.folder]) else {
            return false
        }

        let items = info.itemProviders(for: ["public.file-url", "file-url"])
        for item in items {
            _ = item.loadObject(ofClass: URL.self) { url, _ in
                if let url = url {
                    DispatchQueue.main.async {
                        print("Uploading...")
                        print(url.absoluteURL)
                        self.localPathURL = url
                        print(url.pathComponents.last ?? "Untitled File")
                    }
                }
            }
        }

        return true
    }
}
