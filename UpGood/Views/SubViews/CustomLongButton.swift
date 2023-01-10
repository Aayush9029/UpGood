//
//  CustomLongButton.swift
//  UpGood
//
//  Created by Aayush Pokharel on 2023-01-10.
//

import SwiftUI

struct CustomLongButton: View {
    let title: String
    let symbol: String
    let action: () -> Void
    init(
        _ title: String,
        symbol: String,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.symbol = symbol
        self.action = action
    }

    var body: some View {
        Button {
            withAnimation {
                action()
            }
        } label: {
            Label(title, systemImage: symbol)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
                .padding(.vertical, 4)
                .background(VisualEffectView.hudMaterial)
                .cornerRadius(12)
        }
        .symbolVariant(.fill)
        .buttonStyle(.borderless)
    }
}

struct CustomLongButton_Previews: PreviewProvider {
    static var previews: some View {
        CustomLongButton(
            "Configure Upload Options",
            symbol: "gear"
        ) {
            print("OK")
        }
        .padding()
    }
}
