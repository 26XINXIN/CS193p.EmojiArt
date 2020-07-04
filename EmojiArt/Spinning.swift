//
//  Spinning.swift
//  EmojiArt
//
//  Created by 杨鑫 on 2020/7/4.
//  Copyright © 2020 杨鑫. All rights reserved.
//

import SwiftUI

// when animating:
// typically modifier is just responsible for changing the
// parameters, and call .animation to make it animates
struct Spinning: ViewModifier {
    @State var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(Angle(degrees: isVisible ? 360: 0))
            .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
            .onAppear { self.isVisible = true }
    }
}

extension View {
    func spinning() -> some View {
        self.modifier(Spinning())
    }
}
