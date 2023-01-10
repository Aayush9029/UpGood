//
//  SelectFolderButton.swift
//  UpGood
//
//  Created by Aayush Pokharel on 2022-04-19.
//

import SwiftUI

struct SelectFolderButton: View {
    @State private var isHovered: Bool = false
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "folder")
                .resizable()
                .scaledToFit()
                .frame(width: 80)
                .foregroundStyle(isHovered ? .secondary : .tertiary)
                .padding()

            Text("Click to add files and folders.")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundStyle(isHovered ? .secondary : .tertiary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(maxWidth: .greatestFiniteMagnitude)
        .padding()
        .background(VisualEffectView.hudMaterial)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    .tertiary,
                    style: StrokeStyle(lineWidth: 1, dash: [isHovered ? 4 : 8])
                )
        )
        .onHover { hoverState in
            withAnimation {
                isHovered = hoverState
            }
        }
    }
}

struct DropHereView_Previews: PreviewProvider {
    static var previews: some View {
        SelectFolderButton()
    }
}
