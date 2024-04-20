//
//  DefaultButtonStyle.swift
//  intersim
//
//  Created by Isley Sepulveda on 4/10/24.
//

import SwiftUI

struct DefaultButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        let label = configuration.label
        let color = configuration.role == .destructive ? Color.red : Color.blue
        
        HStack {
            Spacer()
            label
            Spacer()
        }
        .font(.system(.title, design: .rounded, weight: .bold))
        .foregroundColor(.white)
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(color)
        }
        .scaleEffect(x: configuration.isPressed ? 0.96 : 1, y: configuration.isPressed ? 0.96 : 1)
    }
}
