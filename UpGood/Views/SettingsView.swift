//
//  SettingsView.swift
//  UpGood
//
//  Created by Aayush Pokharel on 2022-05-31.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var upVM: UpGoodViewModel

    let daysColumn = [
        GridItem(.adaptive(minimum: 32))
    ]
    let downloadsColumn = [
        GridItem(.adaptive(minimum: 48))
    ]

    var body: some View {
        VStack {
            TitleView(
                title: "UpGood",
                subtitle: "Settings",
                urlTitle: "Made by Aayush",
                url: Constants.githubURL
            )

            VStack(alignment: .leading) {
                Label(
                    "Store files for \(upVM.maxDays) days",
                    systemImage: "server.rack"
                )
                .foregroundStyle(.secondary)

                LazyVGrid(columns: daysColumn) {
                    ForEach(Constants.storeOptions, id: \.self) { value in
                        SelectButton(
                            setValue: $upVM.maxDays,
                            value: value
                        )
                    }
                }
            }
            .padding(.top, 8)

            Divider()

            VStack(alignment: .leading) {
                Label(
                    "Expire after \(upVM.maxDownloads) downloads",
                    systemImage: "timer"
                )
                .foregroundStyle(.secondary)

                LazyVGrid(columns: downloadsColumn) {
                    ForEach(Constants.downloadsOptions, id: \.self) { option in
                        SelectButton(
                            setValue: $upVM.maxDownloads,
                            value: option
                        )
                    }
                }
            }

            Button {
                withAnimation {
                    upVM.currentPage = .upload
                }
            } label: {
                Label("Save Upload Options", systemImage: "checkmark.circle")
            }
            .buttonStyle(.plain)
            .padding(.top, 8)
        }.padding()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .padding(.top, 6)
            .frame(width: 280, height: 360)
            .environmentObject(UpGoodViewModel())
    }
}

// MARK: - Single Select Button

struct SelectButton: View {
    @Binding var setValue: Int
    let value: Int
    var body: some View {
        Text("\(value)")
            .bold()
            .frame(maxWidth: .greatestFiniteMagnitude)
            .padding(.vertical, 6)
            .background(
                .blue.opacity(setValue == value ? 1 : 0.125)
            )
            .cornerRadius(4)
            .onTapGesture {
                withAnimation {
                    setValue = value
                }
            }
    }
}
