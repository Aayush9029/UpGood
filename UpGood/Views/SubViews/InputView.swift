//
//  InputView.swift
//  UpGood
//
//  Created by Aayush Pokharel on 2022-04-19.
//

import SwiftUI

struct InputView: View {
    @EnvironmentObject var upVM: UpGoodViewModel

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                if let path = upVM.localPathURL {
                    ZStack {
                        Image("cloud")
                            .resizable()
                            .blur(radius: 32)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 16)
                            )
                            .overlay(
                                RoundedRectangle(
                                    cornerRadius: 16
                                )
                                .stroke(
                                    .tertiary,
                                    style: StrokeStyle(lineWidth: 2, dash: [8])
                                )
                            )

                        Group {
                            VStack {
                                Spacer()
                                Image(systemName: "folder.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 64)

                                Text(path.lastPathComponent)
                                    .multilineTextAlignment(.center)

                                Spacer()

                                HStack {
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 12)
                                            .frame(height: 4)
                                            .foregroundStyle(.gray)

                                        RoundedRectangle(cornerRadius: 12)
                                            .frame(height: 4)
                                            .foregroundStyle(.blue)
                                            .frame(width: 64)
                                    }
                                    Text("29.24%")
                                        .font(.caption2)
                                }
                            }
                            .padding()
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .background(.ultraThinMaterial)
                            .cornerRadius(16)
                            .shadow(radius: 8)
                            .padding()
                        }
                    }
                }
                else {
                    SelectFolderButton()
                }
            }
            .onTapGesture {
                selectFile()
            }
        }
    }

    private func selectFile() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false

        if panel.runModal() == .OK {
            upVM.localPathURL = panel.url
        }
    }
}

struct InputView_Previews: PreviewProvider {
    static var previews: some View {
        InputView()
            .frame(width: 220)
            .environmentObject(
                UpGoodViewModel.previewProvider
            )
            .padding()
    }
}
