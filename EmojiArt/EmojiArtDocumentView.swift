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

// Persistence
// storing data on the device permenently, user data
// ways:
//  FileManager: save to file system
//  CoreData: a SQL database
//  iCloud: interoperates with above
//  CloudKit: a database in the cloud
//  simplest way: UserDefaults "persistent dictionary",
//      store something like user preference, lightweight, not for big data
//      "ancient" API
//      limited data types: Perperty List: comb of String, Int, Bool, Float/Double, Date, Data, Array, Dictionary
//      Codable: a protocol to convert object into Data struct
// Any Type: any == untyped
// Using UserDefaults:
//      let defaults = UserDefaults.standard
//      defaults.set(object, forKey: "SomeKey") // object must be a Property List
//      defualts.setDouble(37.5, forKey; "MyDouble")
//      let i: Int = defaults.integer(forKey: "MyInt")
//      let b: Data? = defaults.data(forKey: "MyData")
//      let u: URL? = defaults.url(forKey: "MyURL")
//      let strings: [String]? = defaults.stringArray(forKey: "MyString")
//      let a = array(forKey: "MyArray") -> Array<Any> need type casting

// Getting Input from User: gestures
//  SwiftUI recognizes the gestures
//  You have to handle each type of gestures
//  start recognizing a gesture: .gesture(theGesture)
//  Creating a gesture: can be a func, computed var or local var
//      var theGesture: some Gesture {return TapGesture(count: 2)}
//  Some guesture are discrete, e.g., TapGuesture, happens all at once
//  Do something when a discrete gesture is recognized:
//      var theGesture: some Gesture {
//          return TapGesture(count: 2)
//              .onEnded { // do something }
//      }
//  Discrete gesture has convenient versions:
//      .onTapGesture(count: Int) {}
//      .onLongPressGesture(...) {}
//  Non-discrete gesture: handle when the fingers are moving
//      e.g. DragGesture, MagnificationGesture, TotationGesture, LongPressGesture
//      var theGesture: some Gesture {
//          return TapGesture(count: 2)
//              .onEnded { value in // do something }
//      }
//      the value tells you the information needed when a gesture is ended
//      e.g. Drag: start and end location of fingers
//           Magnification: scale of the magnification
//           Rotation: Angle of the rotation
//      do something when it's changing
//      @GestureState var myGestureState: MyGestureStateType (any type, CGFloat, etc.) = <starting value>
//      used to store information during the gesture
//      is the state var only when the gesture is happening
//          var theGesture: some Gesture {
//              DragGesture(...)
//                  .updating($myGestureState) { value, myGestureState, transaction in
//                      myGestureState = ...
//                  }
//                  .onChanged { value in ... }
//                  .onEnded { value in ... }
//          }
//      value is the same as that in .onEnded
//      this is the only way to change @GestureState, because it changes only when animation
//      ignoring transaction here
//      .onChanged can not modify @GestureState, used when don't tracking states, e.g. finger like a pen
//


import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    
    var body: some View {
        VStack{
            // make it scroll
            ScrollView(.horizontal){
                HStack {
                    // map {String($0)} take a single char and turn it into a string
                    // '\' is key path, directing to the correct object instance
                    ForEach(EmojiArtDocument.palette.map {String($0)}, id: \.self) { emoji in
                        Text(emoji)
                            .font(Font.system(size: self.defaultEmojiSize))
                            // NS-thing is from Objective-C
                            .onDrag { return NSItemProvider(object: emoji as NSString) }
                    }
                }
            }
                .padding(.horizontal) // setting the scroll space
            // Here will be our model
            // Our model's state is the background and
            // all the emojis on it and their position and size
            // Use Rectangle Overlayed by Image is of consideration of sizing
            // Not using ZStack here
            GeometryReader { geometry in
                ZStack {
                    Rectangle().foregroundColor(.white).overlay(
                        // showing a image that might be nil
                        OptionalImage(uiImage: self.document.backgroundImage)
                            .scaleEffect(self.zoomScale)
                    )
                        .gesture(self.doubleTapToZoom(in: geometry.size))
                    ForEach(self.document.emojis) { emoji in
                        Text(emoji.text)
                            .font(animatableWithSize: self.zoomScale)
                            .position(self.position(for: emoji, in: geometry.size))
                    }
                }
                // all contents show be in the space offerded
                .clipped()
                .gesture(self.zoomGesture())
                // only draw on save area
                .edgesIgnoringSafeArea([.horizontal, .bottom])
                // "puclic.image" is URI
                // isTargeted is binding
                // provider: NSItemProvider
                .onDrop(of: ["public.image", "public.text"], isTargeted: nil) { providers, location in
                    var location = geometry.convert(location, from: .global) // upper-left in this geometry
                    location = CGPoint(x: location.x - geometry.size.width/2, y: location.y - geometry.size.height/2)
                    location = CGPoint(x: location.x / self.zoomScale, y: location.y / self.zoomScale)
                    print("dropping emoji at \(location), from origin \(geometry.convert(location, from: .global)), zoomScale = \(self.zoomScale)")
                    return self.drop(providers: providers, at: location)
                }
            }
        }
    }
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation {
                    self.zoomToFit(self.document.backgroundImage, in: size)
                }
                
            }
    }
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { lastestGestureScale, gestureZoomScale, transaction in
                gestureZoomScale = lastestGestureScale
                
            }
            .onEnded { finalGestureScale in
                self.steadyStateZoomScale *= finalGestureScale
                // the gestureZoomScale will become 1.0 after the gesture
            }
    }
    
    @State private var steadyStateZoomScale: CGFloat = 1.0
    @GestureState private var gestureZoomScale: CGFloat = 1.0
    
    private var zoomScale: CGFloat {
        steadyStateZoomScale * gestureZoomScale
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            self.steadyStateZoomScale = min(hZoom, vZoom)
        }
    }
    
    // TODO: Gesture Pan
    
    private func position(for emoji: EmojiArt.Emoji, in size: CGSize) -> CGPoint {
        var location = emoji.location
        location = CGPoint(x: location.x * zoomScale, y: location.y * zoomScale)
        location = CGPoint(x: emoji.location.x + size.width/2, y: emoji.location.y + size.height/2)
        return location
    }
    
    private func drop(providers: [NSItemProvider], at location: CGPoint) -> Bool {
        // load the image from url
        var found = providers.loadFirstObject(ofType: URL.self) { url in
            print("dropped \(url)")
            self.document.setBackgroundURL(url)
        }
        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                self.document.addEmoji(string, at: location, size: self.defaultEmojiSize)
            }
        }
        return found
    }
    
    private let defaultEmojiSize: CGFloat = 40
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(document:EmojiArtDocument())
    }
}





//extension String: Identifiable {
//    // public means non-private in the library
//    public var id: String { return self }
//}
