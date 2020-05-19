//
//  ViewController.swift
//  ARDicee
//
//  Created by Donald Seo on 2020-05-18.
//  Copyright © 2020 Donald Seo. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var diceArray = [SCNNode]()

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        debug option dots on screen
//        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Set the view's delegate
        sceneView.delegate = self
        
        //units are in Meters
        //chamferRadius => roundedness
//        let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
        
//        let sphere = SCNSphere(radius: 0.2)
//        
//        let material = SCNMaterial()
//        
//        material.diffuse.contents = UIImage(named: "art.scnassets/8k_earth_daymap.jpg")
//        
//        sphere.materials = [material]
//        
//        let node = SCNNode()
//        
//        //negative Z => away from you
//        node.position = SCNVector3(x: 0, y: 0.1, z: -0.5)
//        
//        node.geometry = sphere
//        
//        sceneView.scene.rootNode.addChildNode(node)
        
        sceneView.autoenablesDefaultLighting = true
//        // Show statistics such as fps and timing information
//        sceneView.showsStatistics = true
//
        // Create a new scene

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
         
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
// MARK: - Dice Rendering Methods
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
                   
            //checking ARHitResult -> looking for real world plane hit
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            //checking SCNHitResult -> checking if node hit test in SCNview
            let hits = sceneView.hitTest(touchLocation, options: nil)
            
            
            if let tappedNode = hits.first?.node {
                tappedNode.removeFromParentNode()
            } else {
                if let hitResult = results.first {
                    addDice(atLocation: hitResult)
                }
            }
        }
    }
    
    func addDice(atLocation location : ARHitTestResult) {
        
        let diceScene = SCNScene(named: "art.scnassets/dice.scn")!
        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {

            diceNode.position = SCNVector3(
                x: location.worldTransform.columns.3.x,
                y: location.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                z: location.worldTransform.columns.3.z
            )

            diceArray.append(diceNode)
            // Set the scene to the view
            sceneView.scene.rootNode.addChildNode(diceNode)
            
            roll(dice: diceNode)
        }
    }
    
    @IBAction func removeAllDice(_ sender: UIBarButtonItem) {
        
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
    }
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        rollAll()
    }
    
    func rollAll() {
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll(dice: dice)
            }
        }
    }
    
    func roll(dice: SCNNode) {
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        
        dice.runAction(
            SCNAction.rotateBy(
                x: CGFloat(randomX * 5),
                y: 0,
                z: CGFloat(randomZ * 5),
                duration: 0.5)
        )
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    // MARK: - ARSCNViewDelete Methods
    //detect horizontal plane and trigger code
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}

        let planeNode = createPlane(withPlaneAnchor: planeAnchor)
        
        node.addChildNode(planeNode)
    }
    
    
    // MARK: - Plane Rendering Methods
    func createPlane(withPlaneAnchor planeAnchor: ARPlaneAnchor) -> SCNNode {
        
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        
        let planeNode = SCNNode()
    
        planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
    
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
    
        let gridMaterial = SCNMaterial()
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
    
        plane.materials = [gridMaterial]
    
        planeNode.geometry = plane
        
        return planeNode
        
    }



}
