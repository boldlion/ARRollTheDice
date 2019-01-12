//
//  ViewController.swift
//  ARRollTheDice
//
//  Created by Bold Lion on 9.01.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var diceArray = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    @IBAction func roll(_ sender: Any) {
        rollAllDice()
    }
    
    @IBAction func deleteAllDice(_ sender: Any) {
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAllDice()
    }
    
    // MARK: - ARSCNViewDelegateMethods
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let planeNode = createNewPlane(withPlaneAnchor: planeAnchor)
        node.addChildNode(planeNode)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            let result = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)

            if let hitResult = result.first {
                addDiceOnPlane(atLocation: hitResult)
            }
        }
    }
    
    func addDiceOnPlane(atLocation location: ARHitTestResult) {
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        
        if let node = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
            node.position = SCNVector3(x: location.worldTransform.columns.3.x,
                                       y: location.worldTransform.columns.3.y + node.boundingSphere.radius,
                                       z: location.worldTransform.columns.3.z)
            
            diceArray.append(node)
            sceneView.scene.rootNode.addChildNode(node)
            roll(dice: node)
        }
    }
    
    func rollAllDice() {
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll(dice: dice)
            }
        }
    }
    
    func roll(dice: SCNNode) {
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi / 2)
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi / 2)
        dice.runAction(
            SCNAction.rotateBy(x: CGFloat(randomX * 5),
                               y: 0,
                               z: CGFloat(randomZ * 5),
                               duration: 0.5)
        )
    }
    
    // MARK: - Plane Rendering Methods
    func createNewPlane(withPlaneAnchor planeAnchor: ARPlaneAnchor) -> SCNNode {
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let planeNode = SCNNode()
        planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0 )
        let gridMaterial = SCNMaterial()
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")!
        plane.materials = [gridMaterial]
        planeNode.geometry = plane
        return planeNode
    }
}
