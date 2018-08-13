//
//  ViewController.swift
//  ARKitFilter
//
//  Created by Josh Robbins on 12/05/2018.
//  Copyright © 2018 BlackMirrorz. All rights reserved.
//

import UIKit
import ARKit

//-----------------------
//MARK: ARSCNViewDelegate
//-----------------------

extension ViewController: ARSCNViewDelegate{
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        DispatchQueue.main.async {
            
            //1. Update The Tracking Status
            self.statusLabel.text = self.augmentedRealitySession.sessionStatus()
            
        }
    }
}

//-----------------------
//MARK: ARSessionDelegate
//-----------------------

extension ViewController: ARSessionDelegate{
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
        if blackAndWhite{
            
            //Convert The Current Frame To Black & White
            guard let currentBackgroundFrameImage = augmentedRealityView.session.currentFrame?.capturedImage,
                let pixelBufferAddressOfPlane = CVPixelBufferGetBaseAddressOfPlane(currentBackgroundFrameImage, 1) else { return }
            
            let x: size_t = CVPixelBufferGetWidthOfPlane(currentBackgroundFrameImage, 1)
            let y: size_t = CVPixelBufferGetHeightOfPlane(currentBackgroundFrameImage, 1)
            memset(pixelBufferAddressOfPlane, 128, Int(x * y) * 2)
        }
    }
}

class ViewController: UIViewController {

    //1. Create A Reference To Our ARSCNView In Our Storyboard Which Displays The Camera Feed
    @IBOutlet weak var augmentedRealityView: ARSCNView!
    
    //2. Create A Reference To Our ARSCNView In Our Storyboard Which Will Display The ARSession Tracking Status
    @IBOutlet weak var statusLabel: UILabel!
    
    //3. Create Our ARWorld Tracking Configuration
    let configuration = ARWorldTrackingConfiguration()
    
    //4. Create Our Session
    let augmentedRealitySession = ARSession()
    
    //5. Create A Variable To Allow Toggling Between Standard & Black & White Camera Feed Rendering
    var blackAndWhite = false
    
    //6. Create A Reference To Our UISegmentedControl To Toggle The Camera Feed
    @IBOutlet var feedController: UISegmentedControl!
    
    //7. Create Our ScatterBug
    var scatterBug = SCNNode()
    
    //8. Store The Rotation Of The ScatterBug
    var currentAngleY: Float = 0.0
    
    //--------------------
    //MARK: View LifeCycle
    //--------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { self.loadScatterBug() }
      
        let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotateBug(_:)))
        self.view.addGestureRecognizer(rotateGesture)
    }

    override func viewDidAppear(_ animated: Bool) {
        
        setupARSession()
      
    }
    
    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }

    //-------------------
    //MARK: Model Loading
    //-------------------
    
    /// Loads Our Little Scatterbug
    func loadScatterBug() {
        
        let modelPath = "ARModels.scnassets/Scatterbug.scn"
        
        //1. Get The Reference To Our SCNScene & Get The Model Root Node
        guard let model = SCNScene(named: modelPath),
              let pokemonModel = model.rootNode.childNode(withName: "RootNode", recursively: false) else { return }
        
        scatterBug = pokemonModel
        
        //2.Add It To Our SCNView
        augmentedRealityView.scene.rootNode.addChildNode(scatterBug)
        
        //3. Scale The Scatterbug
        scatterBug.scale = SCNVector3(0.02, 0.02, 0.02)
        
        //4. Add Him To The Scene
        scatterBug.position = SCNVector3(0, 0, -1.5)
        
        augmentedRealityView.scene.rootNode.addChildNode(scatterBug)
        
    }
    
    //-----------------------
    //MARK: Model Interaction
    //-----------------------
    
    /// Rotates The ScatterBug Around It's YAxis
    ///
    /// - Parameter gesture: UIRotationGestureRecognizer
    @objc func rotateBug(_ gesture: UIRotationGestureRecognizer){
        
        //1. Get The Current Rotation From The Gesture
        let rotation = Float(gesture.rotation)
        
        //2. If The Gesture State Has Changed Set The Nodes EulerAngles.y
        if gesture.state == .changed{
            
            scatterBug.eulerAngles.y = currentAngleY + rotation
        }
        
        //3. If The Gesture Has Ended Store The Last Angle Of The ScatterBug
        if gesture.state == .ended {

            currentAngleY = scatterBug.eulerAngles.y
           
        }
    }
    
    //------------------------------
    //MARK: Black And White Toggling
    //------------------------------
    
    /// Toggles The Setting Of The Camera Feed
    ///
    /// - Parameter controller: UISegmentedController
    @IBAction func toggleCameraFeed(_ controller: UISegmentedControl){
 
        if controller.selectedSegmentIndex == 1{
            blackAndWhite = true
        }else{
            blackAndWhite = false
        }
        
    }
    
    //---------------
    //MARK: ARSession
    //---------------
    
    /// Sets Up The ARSession
    func setupARSession(){
        
        //1. Set The AR Session
        augmentedRealityView.session = augmentedRealitySession
        augmentedRealitySession.delegate = self
        augmentedRealityView.delegate = self
        
        //2. Conifgure The Type Of Plane Detection
        configuration.planeDetection = [planeDetection(.Vertical)]
        
        //3. Configure The Debug Options
        augmentedRealityView.debugOptions = debug(.None)
        augmentedRealityView.showsStatistics = true
        
        //4. Run The Session
        augmentedRealitySession.run(configuration, options: runOptions(.ResetAndRemove))
        
        
    }

}

