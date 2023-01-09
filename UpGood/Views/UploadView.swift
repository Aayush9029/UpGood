//
//  UploadView.swift
//  UpGood
//
//  Created by Aayush Pokharel on 2022-05-31.
//

import Combine
import SwiftUI

struct UploadView: View {
    @State var localPathURL: URL?
    @EnvironmentObject var upVM: UpGoodViewModel

    var body: some View {
        VStack {
            TitleView(
                title: "Upload",
                subtitle: "File",
                urlTitle: "Powered by transfer.sh",
                url: Constants.transferURL
            )

            InputView(localPathURL: $localPathURL)

            Button {
                withAnimation { upVM.currentPage = .settings }
            } label: {
                Label("Configure Upload Options", systemImage: "gear")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.borderless)
            
        }.padding(.vertical)
            .onChange(of: localPathURL) { _ in
                guard let localPathURL = localPathURL else {
                    return
                }
                Task {
                    do {
                        let pub = try await upVM.fileUploader.uploadFile(at: localPathURL)
                        print(pub.1)
                    }
                    catch {
                        print(error.localizedDescription)
                    }
                }
            }
    }
}

struct UploadView_Previews: PreviewProvider {
    static var previews: some View {
        UploadView()
            .environmentObject(UpGoodViewModel())
            .frame(width: 280, height: 360)
    }
}