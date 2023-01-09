//
//  InputView.swift
//  UpGood
//
//  Created by Aayush Pokharel on 2022-04-19.
//

import SwiftUI

struct InputView: View {
    @Binding var localPathURL: URL?

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                if localPathURL != nil {
                    ZStack {
                        Image("cloud")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .blur(radius: 2)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(.tertiary, style: StrokeStyle(lineWidth: 2, dash: [8]))
                            )
                    }
                } else {
                    DropHereView()
                }
            }

            .onDrop(
                of: ["public.url", "public.file-url", "file-url"],
                delegate: UrlsDropDelegate(localPathURL: $localPathURL)
            )
            .onTapGesture {
                selectFile()
            }
        }
    }

    private func selectFile() {
        NSOpenPanel.openFile { result in
            if case let .success(url) = result {
                localPathURL = url
            }
        }
    }
}

struct InputView_Previews: PreviewProvider {
    static var previews: some View {
        InputView(localPathURL: .constant(Constants.transferURL))
            .padding()
    }
}
