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
        sceneView.alpha = 0
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
        
        // Create a new scene
        sceneView.scene = SCNScene()
        
        // Set the lighting for the scene
        let environment = UIImage(named: "env.jpg")
        sceneView.scene.lightingEnvironment.contents = environment
        sceneView.scene.lightingEnvironment.intensity = 8
        
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
        configuration.isAutoFocusEnabled = true
        
        // Tell ARKit to look for horizontal planes
        configuration.planeDetection = .horizontal

        // Run the view's session!
        sceneView.session.run(configuration)
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        

        animateFromLaunchScreenToMainScene()
        
        // Add the head sculpture at the start of the app for debugging
        // spawnModelWithPositionAndScale(position: SCNVector3(0, 0, -3), scale: SCNVector3(0.3, 0.3, 0.3))
        
    }
    
    func animateFromLaunchScreenToMainScene() {
        
        UIView.animate(withDuration: 1, delay: 1, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.sceneView.alpha = 1
        }, completion: nil)
        
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
    
     func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // 1. Unwrap anchor as an ARPlaneAnchor
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }

        // 2. Create the SCNPlane
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)

        // 3. Set plane materials
        // plane.materials.first?.diffuse.contents = UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 0.8)
        plane.materials.first?.diffuse.contents = UIColor.clear

        // 4. Create a node with the plane geometry
        let planeNode = SCNNode(geometry: plane)
        
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
        planeNode.eulerAngles.x = -Float.pi/2
        
        node.addChildNode(planeNode)
        
        if (currSpawnCount < maxSpawnCount) {
            
            planeNode.addChildNode(self.createHeadNode())
            
            // Add a smoke particle system to the plane node
            let particleSystem = SCNParticleSystem(named: "SmokeParticleSystem", inDirectory: nil)
            let particleNode = SCNNode()
            particleNode.addParticleSystem(particleSystem!)
            
            planeNode.addChildNode(particleNode)
            
            currSpawnCount += 1
        }
     }
    
    func createGoldMaterial() -> SCNMaterial {
        
        let material = SCNMaterial()
        material.lightingModel = SCNMaterial.LightingModel.physicallyBased
        material.fresnelExponent = 1.5
        material.diffuse.contents = UIImage(named: "albedo.png")
        material.roughness.contents = UIImage(named: "roughness.png")
        material.metalness.contents = UIImage(named: "metalness.png")
        material.normal.contents = UIImage(named: "normal.png")
        material.shininess = 50
        
        return material
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        node.eulerAngles = SCNVector3(0, 0, 0)
    }
    
    
    /*
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
 */
    
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
 
            
            if (currSpawnCount < maxSpawnCount) {
                 addSculptureToSceneView(tapLocation: tapLocation)
                currSpawnCount += 1
            }
            */
            
        }
        
    }
    
    /*
    // Spawn the model where the tap occurred on the horizontal plane
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
 */
    
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
    
    func createHeadNode() -> SCNNode {
        let scene = SCNScene(named: "goldHead_TS.scn")
        let headNode: SCNNode! = scene?.rootNode.childNode(withName: "head", recursively: true)
        
        // Create the gold material and add it to the heads
        let goldMaterial = self.createGoldMaterial()
        
        headNode.childNode(withName: "C061_Untitled.035", recursively: true)?.geometry?.firstMaterial = goldMaterial
        headNode.childNode(withName: "C061_Untitled", recursively: true)?.geometry?.firstMaterial = goldMaterial
        
        // Scale and position the head node
        headNode.scale = SCNVector3(0, 0, 0)
        headNode.position = SCNVector3(0, 0, 0)
        headNode.eulerAngles.x = Float.pi * 0.5
        
        // Animate scaling
        let action = SCNAction.scale(to: 0.25, duration: 5)
        headNode.runAction(action)
        
        playAudioFromNode(node: headNode)
        
        return headNode
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
    
//    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
//        guard let estimate = self.sceneView.session.currentFrame?.lightEstimate else {
//            return
//        }
//
//        // print("light estimate: %f", estimate.ambientIntensity)
//
//        // Change intensity property of lights to respond to real world environment
//        let intensity = estimate.ambientIntensity / 170.0
//
////        print(intensity)
////        sceneView.scene.lightingEnvironment.intensity = intensity
//
//    }
}
