//
//  CustomModifiers.swift
//  Step Tracker
//
//  Created by Arseny Prostakov on 09/11/2025.
//

import SwiftUI

struct ProminentButton: ViewModifier {
    
    var color: Color
    
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .buttonStyle(.glassProminent)
                .tint(color)
        } else {
            content
                .buttonStyle(.borderedProminent)
                .tint(color) 
        }
    }
}

extension View {
    func prominentButton(color: Color) -> some View {
        modifier(ProminentButton(color: color))
    }
}
