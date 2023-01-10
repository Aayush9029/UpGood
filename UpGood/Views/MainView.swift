//
//  MainView.swift
//  UpGood
//
//  Created by Aayush Pokharel on 2022-04-19.
//

import SwiftUI

struct MainView: View {
    @StateObject var upVM: UpGoodViewModel = .init()

    var body: some View {
        VStack {
            switch upVM.currentPage {
            case .upload:
                UploadView()
                    .environmentObject(upVM)
            case .options:
                UploadOptionsView()
                    .environmentObject(upVM)
            }
        }.transition(.slide)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .frame(width: 280, height: 360)
    }
}
