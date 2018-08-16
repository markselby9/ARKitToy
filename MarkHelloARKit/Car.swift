//
//  Car.swift
//  MarkHelloARKit
//
//  Created by 冯超逸 on 2018/8/16.
//  Copyright © 2018 Mark Feng. All rights reserved.
//

import Foundation
import SceneKit

class Car :SCNNode {
    
    var carNode :SCNNode
    
    private var zVelocityOffset = 0.1
    
    init(node: SCNNode) {
        
        self.carNode = node
        super.init()
        self.addChildNode(self.carNode)
        
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        self.physicsBody?.categoryBitMask = PhysicsCategory.car.rawValue
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func go() {
        let force = simd_make_float4(8,0,-4,0)
        let rotatedForce = simd_mul(self.presentation.simdTransform, force)
        let vectorForce = SCNVector3(rotatedForce.x, rotatedForce.y, rotatedForce.z)
        self.physicsBody?.applyForce(vectorForce, asImpulse: false)
    }
    
    func back() {
        let force = simd_make_float4(-8,0,4,0)
        let rotatedForce = simd_mul(self.presentation.simdTransform, force)
        let vectorForce = SCNVector3(rotatedForce.x, rotatedForce.y, rotatedForce.z)
        self.physicsBody?.applyForce(vectorForce, asImpulse: false)
    }
    
    func turnRight() {
        
        self.physicsBody?.applyTorque(SCNVector4(0,1,0,-1), asImpulse: false)
    }
    
    func turnLeft() {
        self.physicsBody?.applyTorque(SCNVector4(0,1,0,1), asImpulse: false)
    }
}

