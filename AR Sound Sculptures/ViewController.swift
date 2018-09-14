//
//  ViewController.swift
//  AR Sound Sculptures
//
//  Created by Matthew Chiang on 9/13/18.
//  Copyright © 2018 Matthew Chiang. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var audioSource: SCNAudioSource!
    let maxSpawnCount = 1
    var currSpawnCount = 0
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
        
        // Create a new scene
        sceneView.scene = SCNScene()
        
        // Set the lighting for the scene
        let environment = UIImage(named: "env.jpg")
        sceneView.scene.lightingEnvironment.contents = environment
        
        // Add tapGestureRecognizer to the view controller
        addTapGestureToSceneView()
        
        // Instantiate the audio source
        setUpAudio(fileName: "sickomode.mp3")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        
        // Tell ARKit to look for horizontal planes
        configuration.planeDetection = .horizontal

        // Run the view's session!
        sceneView.session.run(configuration)
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Add the head sculpture at the start of the app for debugging
        // spawnModelWithPositionAndScale(position: SCNVector3(0, 0, -3), scale: SCNVector3(0.3, 0.3, 0.3))
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    // MARK: - Plane Detection
    
    /*
     func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
         // 1. Unwrap anchor as an ARPlaneAnchor
         guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
         // 2. Create the SCNPlane
         let width = CGFloat(planeAnchor.extent.x)
         let height = CGFloat(planeAnchor.extent.z)
         let plane = SCNPlane(width: width, height: height)
        
         // 3. Set plane materials
         plane.materials.first?.diffuse.contents = UIColor.blue
        
         // 4. Create a node with the plane geometry
         let planeNode = SCNNode(geometry: plane)
        
         let x = CGFloat(planeAnchor.center.x)
         let y = CGFloat(planeAnchor.center.y)
         let z = CGFloat(planeAnchor.center.z)
         planeNode.position = SCNVector3(x, y, z)
         planeNode.eulerAngles.x = -Float.pi/2
        
        node.addChildNode(planeNode)
        
     }
 */
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // 1. Extract previous ARPlaneAnchor, SCNNode, and SCNplane
        guard let planeAnchor = anchor as? ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        // 2. Update plane's width and height
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height
        
        // 3. Update planeNode's position
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
        
    }
    
    // MARK: - Touch Gestures
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        // guard let sceneView = sender.view as? ARSCNView else { return }
        let tapLocation = sender.location(in: sceneView)
        
        let hitTestResult = sceneView.hitTest(tapLocation, options: [SCNHitTestOption.categoryBitMask : HitTestType.sculpture.rawValue] )
        if !hitTestResult.isEmpty {
            
            /*
            if var lucas = hitTestResult.first!.node.parentWithName("lucas") {
                (lucas as! ColladaNode).activate()
            } else {
                // Add Lucas to the plane. Lucas only be added on a plane
                addLucasToSceneView(tapLocation: tapLocation)
            }
             */
            
            if (currSpawnCount < maxSpawnCount) {
                 addSculptureToSceneView(tapLocation: tapLocation)
                currSpawnCount += 1
            }
            
        }
        
    }
    
    // Spawn the model where the tap occured on the horizontal plane
    func addSculptureToSceneView(tapLocation: CGPoint) {
        let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)

        // Get the x, y, and z from the tap location of the existing plane
        guard let hitTestResult = hitTestResults.first else { return }

        let translation = hitTestResult.worldTransform.columns.3
        let x = translation.x
        let y = translation.y
        let z = translation.z

        spawnModelWithPositionAndScale(position: SCNVector3(x, y, z), scale: SCNVector3(0.3, 0.3, 0.3))
    }
    
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // MARK: - Spawning Models
    
    func spawnModelWithPositionAndScale(position: SCNVector3, scale: SCNVector3) {
        
        let scene = SCNScene(named: "goldHead_TS.scn")
        let headNode: SCNNode! = scene?.rootNode.childNode(withName: "head", recursively: true)
        
        playAudioFromNode(node: headNode)
        
        headNode.position = SCNVector3(position.x, position.y, position.z)
        headNode.scale = SCNVector3(scale.x, scale.y, scale.z)
        
        sceneView.scene.rootNode.addChildNode(headNode)
    }
    
    // MARK: - Playing Audio
    
    func setUpAudio(fileName: String) {
        audioSource = SCNAudioSource(fileNamed: fileName)
        audioSource.loops = true
        audioSource.load()
    }
    
    func playAudioFromNode(node: SCNNode) {
        node.addAudioPlayer(SCNAudioPlayer(source: audioSource))
        
        let play = SCNAction.playAudio(audioSource, waitForCompletion: false)
        node.runAction(play)
    }
    

    // MARK: - ARSCNViewDelegate
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let estimate = self.sceneView.session.currentFrame?.lightEstimate else {
            return
        }
        
        // print("light estimate: %f", estimate.ambientIntensity)
        
        // Change intensity property of lights to respond to real world environment
        let intensity = estimate.ambientIntensity / 100.0
        sceneView.scene.lightingEnvironment.intensity = intensity
        
    }
}
