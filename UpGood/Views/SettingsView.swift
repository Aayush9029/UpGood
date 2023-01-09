//
//  SettingsView.swift
//  UpGood
//
//  Created by Aayush Pokharel on 2022-05-31.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var upVM: UpGoodViewModel

    let dayColumn = [
        GridItem(.adaptive(minimum: 32))
    ]
    let downloadColumn = [
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

                LazyVGrid(columns: dayColumn) {
                    ForEach(Constants.storeOptions, id: \.self) { value in
                        SelectButton(
                            value: String(value),
                            color: .blue.opacity(upVM.maxDays == value ? 1 : 0.125)
                        ) {
                            upVM.maxDays = value
                        }
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

                LazyVGrid(columns: downloadColumn) {
                    ForEach(Constants.downloadsOptions, id: \.self) { option in
                        SelectButton(
                            value: String(option),
                            color: .blue.opacity(upVM.maxDownloads == option ? 1 : 0.125)
                        ) {
                            upVM.maxDownloads = option
                        }
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
    let value: String
    let color: Color
    let action: () -> Void

    init(value: String, color: Color, action: @escaping () -> Void) {
        self.value = value
        self.color = color
        self.action = action
    }

    var body: some View {
        Text("\(value)")
            .bold()
            .frame(maxWidth: .greatestFiniteMagnitude)
            .padding(.vertical, 6)
            .background(color)
            .cornerRadius(4)
            .onTapGesture {
                withAnimation {
                    action()
                }
            }
    }
}
