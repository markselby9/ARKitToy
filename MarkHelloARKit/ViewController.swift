//
//  ViewController.swift
//  MarkHelloARKit
//
//  Created by 冯超逸 on 2018/8/4.
//  Copyright © 2018 Mark Feng. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

enum PhysicsCategory : Int{
    case box = 1
    case plane = 2
}

class ViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet var sceneView: ARSCNView!
    
    private let textLabel :UILabel = UILabel()
    var boxes = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textLabel.frame = CGRect(x: 0, y: 0, width: self.sceneView.frame.size.width, height: 44)
        self.textLabel.center = self.sceneView.center
        self.textLabel.textAlignment = .center
        self.textLabel.textColor = UIColor.white
        self.textLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        self.textLabel.alpha = 0
        sceneView.addSubview(self.textLabel)
        
        // Set the view's delegate
        sceneView.delegate = self
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints,ARSCNDebugOptions.showWorldOrigin]

        // Create a new scene
        let scene = SCNScene()
        // Set the scene to the view
        sceneView.scene = scene
        
        let carScene = SCNScene(named: "art.scnassets/car.dae")
        let carNode = carScene?.rootNode.childNode(withName: "car", recursively: true)
        carNode?.position = SCNVector3(0, 0, 0.5)
        scene.rootNode.addChildNode(carNode!)
        
        _registerGesture()
    }
    
    private func _registerGesture() {
        let singleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedFunc))
//        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTappedFunc))
//        doubleTapRecognizer.numberOfTapsRequired = 2
//        singleTapRecognizer.require(toFail: doubleTapRecognizer)
        
        self.sceneView.addGestureRecognizer(singleTapRecognizer)
    }
    
    @objc func tappedFunc(recognizer :UIGestureRecognizer) {
        let sceneView = recognizer.view as! ARSCNView
        let touchLocation = recognizer.location(in: sceneView)
        
        let hitTestResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        if !hitTestResult.isEmpty {
            guard let hitResult = hitTestResult.first else {return}
            addBox(hitResult: hitResult)
        }
    }

    
    @objc func addBox(hitResult :ARHitTestResult) {
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.blue
        
        box.materials = [material]
        let boxNode = SCNNode(geometry: box)
        boxNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        boxNode.physicsBody?.categoryBitMask = PhysicsCategory.box.rawValue
        
        self.boxes.append(boxNode)
        
        boxNode.position = SCNVector3(hitResult.worldTransform.columns.3.x,hitResult.worldTransform.columns.3.y + Float(box.height/2), hitResult.worldTransform.columns.3.z)
        self.sceneView.scene.rootNode.addChildNode(boxNode)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            self.textLabel.text = "New plane detected"
            UIView.animate(withDuration: 3, animations: {
                self.textLabel.alpha = 1.0
            }) { (completion: Bool) in
                self.textLabel.alpha = 0.0
            }
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
