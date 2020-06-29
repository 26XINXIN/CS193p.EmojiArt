//
//  OptionalImage.swift
//  EmojiArt
//
//  Created by 杨鑫 on 2020/6/28.
//  Copyright © 2020 杨鑫. All rights reserved.
//

import SwiftUI

struct OptionalImage: View {
    var uiImage: UIImage?
    
    var body: some View {
        Group {
            if uiImage != nil {
                Image(uiImage: uiImage!)
            }
        }
    }
}
