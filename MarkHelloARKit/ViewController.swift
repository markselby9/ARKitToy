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
    case car = 3
}

enum SelectedButtonType: Int {
    case Left
    case Right
    case Go
}

class ViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet var sceneView: ARSCNView!
    
    private let textLabel :UILabel = UILabel()
    private var car :Car!
    var boxes = [SCNNode]()
    var planes = [OverlayPlane]()
    
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
        
        let carScene = SCNScene(named: "art.scnassets/car2.dae")
//        car model comes from https://poly.google.com/view/7bF7UVAoYRG
        guard let carNode = carScene?.rootNode.childNode(withName: "car", recursively: true) else {
            return
        }
        self.car = Car(node: carNode)
        
        _registerGesture()
        _addControlPanel()
    }
    
    private func _registerGesture() {
        let singleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedFunc))
//        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTappedFunc))
//        doubleTapRecognizer.numberOfTapsRequired = 2
//        singleTapRecognizer.require(toFail: doubleTapRecognizer)
        
        self.sceneView.addGestureRecognizer(singleTapRecognizer)
    }
    
    private func _addControlPanel() {
        let leftButton = GameButton(frame: CGRect(x: 10, y: self.sceneView.frame.height - 100, width: 50, height: 50)) {
            self.car.turnLeft()
        }
        leftButton.setTitle("Left", for: .normal)
        leftButton.backgroundColor = UIColor.blue
        let rightButton = GameButton(frame: CGRect(x: 70, y: self.sceneView.frame.height - 100, width: 50, height: 50)) {
            self.car.turnRight()
        }
        rightButton.setTitle("Right", for: .normal)
        rightButton.backgroundColor = UIColor.blue
        let goButton = GameButton(frame: CGRect(x: 130, y: self.sceneView.frame.height - 100, width: 50, height: 50)) {
            self.car.go()
        }
        goButton.setTitle("GOGOGO", for: .normal)
        goButton.backgroundColor = UIColor.red
        let backButton = GameButton(frame: CGRect(x: 190, y: self.sceneView.frame.height - 100, width: 50, height: 50)) {
            self.car.back()
        }
        backButton.setTitle("Back", for: .normal)
        backButton.backgroundColor = UIColor.red
        
//        leftButton.tag = SelectedButtonType.Left.rawValue
//        rightButton.tag = SelectedButtonType.Right.rawValue
//        goButton.tag = SelectedButtonType.Go.rawValue
//        backButton.tag = SelectedButtonType.Back.rawValue
        
        self.sceneView.addSubview(leftButton)
        self.sceneView.addSubview(rightButton)
        self.sceneView.addSubview(goButton)
        self.sceneView.addSubview(backButton)
    }
    
//    @objc func pressed(sender: UIButton!) {
//        switch sender.tag {
//        case SelectedButtonType.Left.rawValue:
//            print ("left")
//        case SelectedButtonType.Right.rawValue:
//            print ("right")
//        case SelectedButtonType.Go.rawValue:
//            print ("go")
//        default:
//            print ("default")
//        }
//    }
    
    @objc func tappedFunc(recognizer :UIGestureRecognizer) {
        let sceneView = recognizer.view as! ARSCNView
        let touchLocation = recognizer.location(in: sceneView)
        
        let hitTestResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        if !hitTestResult.isEmpty {
            guard let hitResult = hitTestResult.first else {return}
            addBox(hitResult: hitResult)
            addCar(hitResult: hitResult)
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
        
        boxNode.position = SCNVector3(hitResult.worldTransform.columns.3.x,hitResult.worldTransform.columns.3.y + Float(box.height)*2, hitResult.worldTransform.columns.3.z)
        self.sceneView.scene.rootNode.addChildNode(boxNode)
    }
    
    @objc func addCar(hitResult :ARHitTestResult) {
        self.car.position = SCNVector3(hitResult.worldTransform.columns.3.x,hitResult.worldTransform.columns.3.y + 0.1, hitResult.worldTransform.columns.3.z)
        self.sceneView.scene.rootNode.addChildNode(self.car)
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
        guard anchor is ARPlaneAnchor else {
            return
        }
        let plane = OverlayPlane(anchor: anchor as! ARPlaneAnchor)
        self.planes.append(plane)
        node.addChildNode(plane)
        
        DispatchQueue.main.async {
            self.textLabel.text = "New plane detected"
            UIView.animate(withDuration: 3, animations: {
                self.textLabel.alpha = 1.0
            }) { (completion: Bool) in
                self.textLabel.alpha = 0.0
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        let plane = self.planes.filter { plane in
            return plane.anchor.identifier == anchor.identifier
            }.first
        
        if plane == nil {
            return
        }
        
        plane?.update(anchor: anchor as! ARPlaneAnchor)
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
