//
//  UploadView.swift
//  UpGood
//
//  Created by Aayush Pokharel on 2022-05-31.
//

import SwiftUI

struct UploadView: View {
    @EnvironmentObject var upVM: UpGoodViewModel

    var body: some View {
        VStack {
            TitleView(
                title: "Upload",
                subtitle: "File",
                urlTitle: upVM.uploadMode == .temporary
                    ? "Powered by Litterbox"
                    : "Powered by Catbox",
                url: upVM.uploadMode == .temporary
                    ? Constants.litterboxURL
                    : Constants.catboxURL
            )

            InputView()
                .environmentObject(upVM)
            Spacer()

            HStack(spacing: 8) {
                CustomLongButton(
                    upVM.uploadMode == .temporary ? "Temporary" : "Permanent",
                    symbol: upVM.uploadMode == .temporary ? "clock" : "infinity"
                ) {
                    upVM.uploadMode = upVM.uploadMode == .temporary ? .permanent : .temporary
                }

                CustomLongButton(
                    "Settings",
                    symbol: "gearshape"
                ) {
                    withAnimation { upVM.currentPage = .options }
                }
            }
        }.padding()
    }
}

struct UploadView_Previews: PreviewProvider {
    static var previews: some View {
        UploadView()
            .frame(width: 320, height: 360)
            .environmentObject(UpGoodViewModel.previewProvider)
    }
}
