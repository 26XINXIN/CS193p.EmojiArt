//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by 杨鑫 on 2020/6/26.
//  Copyright © 2020 杨鑫. All rights reserved.
//

import SwiftUI

class EmojiArtDocument: ObservableObject {
    static let palette: String = "🚐🚣🏼👻🍎🦒"
    
    // @Published // workaround for property observer problem with property wrappers
    private var emojiArt: EmojiArt {
        willSet { objectWillChange.send() }
        didSet {
            // print out the json encoded information everytime the model is changed
            // print("json = \(emojiArt.json? .utf8 ?? "nil")")
            // everytime changes happen, save to UserDefault
            // whan it to actually write to disk, you need to switch to another app then switch back
            UserDefaults.standard.set(emojiArt.json, forKey: EmojiArtDocument.untitled)
        }
    }
    
    private static let untitled = "EmojiArtDocument.Untitled"
    
    init() {
        emojiArt = EmojiArt(json: UserDefaults.standard.data(forKey: EmojiArtDocument.untitled)) ?? EmojiArt()
        fetchBackgroundImageData()
    }
    
    @Published private(set) var backgroundImage: UIImage?
    
    var emojis: [EmojiArt.Emoji] { emojiArt.emojis }
    
    // MARK: - Intent(s)
    
    func addEmoji(_ emoji: String, at location: CGPoint, size: CGFloat) {
        emojiArt.addEmoji(emoji, x: Int(location.x), y: Int(location.y), size: Int(size))
    }
    
    func moveEmoji(_ emoji: EmojiArt.Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArt.Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrEven))
        }
    }
    
    func setBackgroundURL(_ url: URL?) {
        emojiArt.backgroundURL = url?.imageURL
        fetchBackgroundImageData()
    }
    
    private func fetchBackgroundImageData() {
        // initial it to nil in case network is very slow
        backgroundImage = nil
        if let url = self.emojiArt.backgroundURL {
            // post the code into a background queue
            DispatchQueue.global(qos: .userInitiated).async {
                // try: exception handling
                if let imageData = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        // if user select another url before this fetching is done
                        if url == self.emojiArt.backgroundURL {
                            self.backgroundImage = UIImage(data: imageData)
                        }
                    }
                }
            }
        }
    }
}

// this vars are not part of a model, they are just for visualization porpuse
// so we can put them here in the view model file
extension EmojiArt.Emoji {
    var fontSize: CGFloat { CGFloat(self.size) }
    var location: CGPoint { CGPoint(x: CGFloat(x), y: CGFloat(y)) }
}
