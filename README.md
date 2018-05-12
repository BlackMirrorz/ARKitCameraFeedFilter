

# ARKitCameraFeedFilter

This project is a basic example of applying a Black & White Filter to the camera feed on an `ARSession`.

*Note that this does not render virtual content in Black & White, only the camera feed itself.*

In order to render all `SceneKit` content in Black & White, you can look at using the following:

 1. `SCNTechnique:` which is a specification for augmenting or postprocessing `SceneKit's` rendering of a scene using additional drawing passes with custom `Metal` or `OpenGL` shaders.
 2. Using the `filters` property of an `SCNNode` which is simply an array of `CoreImage` filters to be applied to the rendered contents of the node.

All the code is fully commented so the apps functionality should be clear to everyone.

**Requirements:**
This project was written in Swift 4, and at the time of writing uses Xcode 9.4 Beta.
The project is setup for iPhone, and in Portrait Orientation.

**Core Functionality:**
The demo project allows you to toggle the colour of the camera feed using a `UISegmentedControl`.

The way in which the camera feed is rendered in  Black & White is manipulating the `CVPixelBuffer` within the the sessions `didUpdateFrame` delegate callback:

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
        //Convert The Current Frame To Black & White
        guard let currentBackgroundFrameImage = augmentedRealityView.session.currentFrame?.capturedImage,
              let pixelBufferAddressOfPlane = CVPixelBufferGetBaseAddressOfPlane(currentBackgroundFrameImage, 1) else { return }
        
        let x: size_t = CVPixelBufferGetWidthOfPlane(currentBackgroundFrameImage, 1)
        let y: size_t = CVPixelBufferGetHeightOfPlane(currentBackgroundFrameImage, 1)
        memset(pixelBufferAddressOfPlane, 128, Int(x * y) * 2)
        
    }

Looking at the `ARSCNView's` statistics during running the app, the `FPS` count remains at 60fps.
