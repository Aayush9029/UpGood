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
                if upVM.fileUploader.isUploading {
                    uploadingView
                } else if let resultURL = upVM.fileUploader.resultURL {
                    successView(resultURL)
                } else if let error = upVM.fileUploader.errorMessage {
                    errorView(error)
                } else if let path = upVM.localPathURL {
                    selectedFileView(path)
                } else {
                    SelectFolderButton()
                }
            }
            .onTapGesture {
                if !upVM.fileUploader.isUploading && upVM.fileUploader.resultURL == nil {
                    selectFile()
                }
            }
        }
    }

    private var uploadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
                .padding()
            Text("Uploading...")
                .font(.title3)
                .foregroundStyle(.secondary)
            Spacer()
            CustomProgressView(progress: upVM.fileUploader.progress)
        }
        .padding()
        .frame(maxWidth: .greatestFiniteMagnitude)
        .background(VisualEffectView.hudMaterial)
        .cornerRadius(16)
    }

    private func successView(_ urlString: String) -> some View {
        VStack {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 48)
                .foregroundStyle(.green)

            Text(urlString)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .textSelection(.enabled)
                .padding(.horizontal)

            Spacer()

            HStack(spacing: 8) {
                CustomLongButton("Copy URL", symbol: "doc.on.doc") {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(urlString, forType: .string)
                }
                CustomLongButton("New Upload", symbol: "arrow.counterclockwise") {
                    upVM.fileUploader.resultURL = nil
                    upVM.fileUploader.errorMessage = nil
                    upVM.localPathURL = nil
                }
            }
        }
        .padding()
        .frame(maxWidth: .greatestFiniteMagnitude)
        .background(VisualEffectView.hudMaterial)
        .cornerRadius(16)
    }

    private func errorView(_ message: String) -> some View {
        VStack {
            Spacer()
            Image(systemName: "xmark.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 48)
                .foregroundStyle(.red)

            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            CustomLongButton("Try Again", symbol: "arrow.counterclockwise") {
                upVM.fileUploader.errorMessage = nil
                upVM.localPathURL = nil
            }
        }
        .padding()
        .frame(maxWidth: .greatestFiniteMagnitude)
        .background(VisualEffectView.hudMaterial)
        .cornerRadius(16)
    }

    private func selectedFileView(_ path: URL) -> some View {
        ZStack {
            Image("cloud")
                .resizable()
                .blur(radius: 32)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.tertiary, style: StrokeStyle(lineWidth: 2, dash: [8]))
                )

            VStack {
                Spacer()
                Image(systemName: iconForFile(path))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48)

                Text(path.lastPathComponent)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                Spacer()

                CustomLongButton("Upload Now", symbol: "arrow.up.circle") {
                    upVM.startUpload()
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

    private func iconForFile(_ url: URL) -> String {
        let ext = url.pathExtension.lowercased()
        switch ext {
        case "png", "jpg", "jpeg", "gif", "webp", "heic":
            return "photo.fill"
        case "mp4", "mov", "avi":
            return "video.fill"
        case "mp3", "wav", "aac":
            return "music.note"
        case "pdf":
            return "doc.richtext.fill"
        case "zip", "tar", "gz":
            return "doc.zipper"
        default:
            return "doc.fill"
        }
    }

    private func selectFile() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false

        if panel.runModal() == .OK {
            upVM.fileUploader.resultURL = nil
            upVM.fileUploader.errorMessage = nil
            upVM.localPathURL = panel.url
        }
    }
}

struct InputView_Previews: PreviewProvider {
    static var previews: some View {
        InputView()
            .frame(width: 320, height: 320)
            .environmentObject(UpGoodViewModel.previewProvider)
            .padding()
    }
}

struct CustomProgressView: View {
    let progress: Double

    var body: some View {
        HStack {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 12)
                        .frame(width: geometry.size.width)
                        .foregroundStyle(.gray)

                    RoundedRectangle(cornerRadius: 12)
                        .foregroundStyle(.blue)
                        .frame(width: max(0, progress * geometry.size.width))
                }
            }.frame(height: 4)

            Text("\(Int(progress * 100))%")
                .font(.caption2)
        }
    }
}
