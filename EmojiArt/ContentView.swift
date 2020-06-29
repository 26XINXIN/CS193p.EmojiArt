//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by 杨鑫 on 2020/6/26.
//  Copyright © 2020 杨鑫. All rights reserved.
//

// Color VS. UIColor
// Color's type differs by context
//  * color-specifier: .foregroundColor(Color.green)
//  * ShapeStype: .fill(Color.blue)
//  * View: Color.white
// UIColor: Used to manipulating colors
//  convert between color spaces
//  Color(uiColor: ) to convert a UIColor to Color and use it anywhere

// Image VS. UIImage
// Image: is a View
//  access images in Assets.xcassets
//  access to system images: Image(systemName: )
//  the system images can be found in a app called SF Symble
//  Human Interface Guidelines: before submitting to AppStore
// UIImage: a image type to stroe/create/manipulate images
//  multiple file formats
//  Image(uiImage: ) to vonvert a UIImage to Image

// Multithreading
//  Not blocking the UI
//  when doing heavy computation: waiting for result but you can't block UI
// Queue: time as the "4th dimension"
// Queue of Closures: when executing, plop a closure on a queue
// Main Queue: used by all iOS systems
//  queue up all the UI actions
// Background Queues: long-lived, non-UI tasks
//  Main queue will always has higher priority than background queue
// GCD (Grand Central Dispatch): the systems
//  fundamental tasks:
//  * getting access to a queue
//  * ploping a block of code on a queue
// Creating a queue
//  DispatchQueue.main // the queue where all UI code must be posted
//  DispatchQueue.global(qos: QoS)  // a non-UI queue with a certain quality of service
//  // some choices of qos (quality of service):
//      .userInteractive            //  do fast, the UI depends on it
//      .userInitiated              // the user just asked to do this, so do it now
//      .utility                    // this needs to hapen, but the user didn't just ask for it
//      .background                 // maintanance tasks (cleanups, etc.)
// Plopping a Closure onto a Queue
// let queue = DispatchQueue.main or DispatchQueue.global(qos: )
// queue.async { ... }  // non-blocking, the closure will be executed sometime later
// queue.sync { ... }   // blocks, waiting for the block to be executed. (never used in UI)
// Nesting:
//  DispatchQueue.global(qos: .userInitialed).async {
//      // do something that might take a long time
//      // this will not block the UI
//      // once calculation is done, it might require a change to the UI
//      // we can't change UI here because this is not the main queue
//      // just post a block of code on the main queue
//      DispatchQueue.main.async { ... }
//  }
// We don't call DispatchQueue.gloabal(qos: ) that much, because we have higher lever APIs
//  e.g. URLSession




import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    
    var body: some View {
        Text("Hello, World!")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(document:EmojiArtDocument)
    }
}
