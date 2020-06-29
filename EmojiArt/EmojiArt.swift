//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by 杨鑫 on 2020/6/26.
//  Copyright © 2020 杨鑫. All rights reserved.
//

import Foundation

// Use Encodable and Decoable simultaniously,
// So Codable = Encodable + Decoable
struct EmojiArt: Codable {
    var backgroundURL: URL? // internet URL or local URL
    var emojis = [Emoji]()
    
    struct Emoji: Identifiable, Codable {
        let text: String
        // coordinates (0, 0) in the center
        var x: Int
        var y: Int
        var size: Int
        // var id = UUID() // overkill
        let id: Int
        
        // only puclic to this file,
        // outside the file, it's private
        // preventing somewhere we are going to change the emoji contnet
        // and the only wey to set the emoji text it through addEmoji(...)
        fileprivate init(text: String, x: Int, y: Int, size: Int, id: Int) {
            self.text = text
            self.x = x
            self.y = y
            self.size = size
            self.id = id
        }
    }
    
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    // failable init
    init?(json: Data?) {
        if json != nil, let newEmojiArt = try? JSONDecoder().decode(EmojiArt.self, from: json!) {
            self = newEmojiArt // allowed to assign self to something else
        } else {
            return nil
        }
    }
    
    // default init
    init() { }
    
    private var uniqueEmojiId = 0
    mutating func addEmoji(_ text: String, x: Int, y: Int, size: Int){
        uniqueEmojiId += 1
        emojis.append(Emoji(text: text, x: x, y: y, size: size, id: uniqueEmojiId))
        
    }
}

