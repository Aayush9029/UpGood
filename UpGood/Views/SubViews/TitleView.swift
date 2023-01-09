//
//  TitleView.swift
//  UpGood
//
//  Created by Aayush Pokharel on 2022-05-31.
//

import SwiftUI

struct TitleView: View {
    let title: String
    let subtitle: String

    let urlTitle: String
    let url: URL

    var body: some View {
        VStack {
            Text("\(Text(title).foregroundColor(.blue)) \(subtitle)")
                .font(.title)
                .fontWeight(.bold)

            Link(urlTitle, destination: url)
                .foregroundStyle(.secondary)
                .padding(.top, -12)
        }
        .frame(maxWidth: .greatestFiniteMagnitude)
    }
}

struct TitleView_Previews: PreviewProvider {
    static var previews: some View {
        TitleView(
            title: "Upload",
            subtitle: "Files",
            urlTitle: "Powered by transfer.sh",
            url: URL(string: "https://transfer.sh")!
        )
        .padding()
    }
}
