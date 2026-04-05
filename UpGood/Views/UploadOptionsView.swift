//
//  UploadOptionsView.swift
//  UpGood
//
//  Created by Aayush Pokharel on 2022-05-31.
//

import SwiftUI

struct UploadOptionsView: View {
    @EnvironmentObject var upVM: UpGoodViewModel

    var body: some View {
        VStack {
            Spacer()
            TitleView(
                title: "UpGood",
                subtitle: "Settings",
                urlTitle: "Made by Aayush",
                url: Constants.githubURL
            )

            VStack(alignment: .leading, spacing: 12) {
                Label("Upload Mode", systemImage: "arrow.up.circle")
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    ForEach(UploadMode.allCases) { mode in
                        SelectStringButton(
                            label: mode.label,
                            isSelected: upVM.uploadMode == mode
                        ) {
                            upVM.uploadMode = mode
                        }
                    }
                }

                Text(upVM.uploadMode.subtitle)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.top, 8)

            if upVM.uploadMode == .temporary {
                Divider()

                VStack(alignment: .leading, spacing: 12) {
                    Label(
                        "Expires after \(upVM.expiryOption.label)",
                        systemImage: "timer"
                    )
                    .foregroundStyle(.secondary)

                    HStack(spacing: 8) {
                        ForEach(ExpiryOption.allCases) { option in
                            SelectStringButton(
                                label: option.label,
                                isSelected: upVM.expiryOption == option
                            ) {
                                upVM.expiryOption = option
                            }
                        }
                    }
                }
            }

            Spacer()

            CustomLongButton(
                "Done",
                symbol: "checkmark.circle"
            ) {
                withAnimation { upVM.currentPage = .upload }
            }
        }
        .padding()
    }
}

struct UploadOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        UploadOptionsView()
            .padding(.top, 6)
            .frame(width: 280, height: 360)
            .environmentObject(UpGoodViewModel())
    }
}

// MARK: - Select Button

struct SelectStringButton: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Text(label)
            .font(.caption)
            .bold()
            .frame(maxWidth: .greatestFiniteMagnitude)
            .padding(.vertical, 6)
            .background(.blue.opacity(isSelected ? 1 : 0.125))
            .cornerRadius(4)
            .onTapGesture {
                withAnimation { action() }
            }
    }
}
