//
//  GameScene.swift
//  Helo_crab
//
//  Created by Federica Mosca on 07/12/23.
//

import Foundation
import SpriteKit
import SwiftUI



class GameScene: SKScene, SKPhysicsContactDelegate{
    @Environment (\.modelContext) private var context
    
    let background = SKSpriteNode(imageNamed: "Background")
    let player = SKSpriteNode(imageNamed: "crab40x40")
    let ground = SKSpriteNode(imageNamed: "Platform")
    let platform = SKSpriteNode(imageNamed: "Platform")
    
    let cam = SKCameraNode()
    
    enum bitmasks: UInt32{
        case player = 0b1
        case platform = 0b10
    }
    
    override func didMove(to view: SKView) {
        self.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        self.anchorPoint = .zero
        
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = 1
        background.setScale(2.5)
        addChild (background)
        
        physicsWorld.contactDelegate = self
        
        ground.position = CGPoint(x: size.width / 2, y: -150)
        ground.zPosition = 5
        ground.setScale (15)
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.allowsRotation = false
        ground.physicsBody?.affectedByGravity = false
        addChild(ground)
        
        player.position = CGPoint(x: size.width / 2, y: size.height / 8)
        player.zPosition = 10
        player.setScale(3.5)
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.height / 2)
        player.physicsBody?.isDynamic = false // later is true
        player.physicsBody?.restitution = 1
        player.physicsBody?.friction = 0
        player.physicsBody?.angularDamping = 0
        player.physicsBody?.categoryBitMask = bitmasks.player.rawValue
        player.physicsBody?.collisionBitMask = 0
        player.physicsBody?.contactTestBitMask = bitmasks.platform.rawValue
        
        addChild (player)
        
        makePlatform()
        
        cam.setScale(1.5)
        camera = cam
    }
    
    override func update(_ currentTime: TimeInterval) {
        cam.position = CGPoint(x: player.position.x, y: player.position.y + 50)
        background.position = CGPoint(x: player.position.x , y: player.position.y)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactA: SKPhysicsBody
        let contactB: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            contactA = contact.bodyA //player
            contactB = contact.bodyB //platform
        }else{
            contactA = contact.bodyB
            contactB = contact.bodyA
        }
        
        if contactA.categoryBitMask == bitmasks.player.rawValue && contactB.categoryBitMask == bitmasks.platform.rawValue{
            
            if player.physicsBody!.velocity.dy < 0 {
                player.physicsBody?.velocity = CGVector(dx: player.physicsBody!.velocity.dx , dy: 700)
                makePlatform2()
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
       for touch in touches {
            let location = touch.location(in: self)
            player.position.x = location.x
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        player.physicsBody?.isDynamic = true
        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 100))
    }
    
    func makePlatform(){
        platform.position = CGPoint(x: size.width / 2, y: size.height / 4)
        platform.zPosition = 5
        platform.setScale(CGFloat(2.5))
        platform.physicsBody = SKPhysicsBody(rectangleOf: platform.size)
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.allowsRotation = false
        platform.physicsBody?.affectedByGravity = false
        platform.physicsBody?.categoryBitMask = bitmasks.player.rawValue
        platform.physicsBody?.collisionBitMask = 0
        platform.physicsBody?.contactTestBitMask = bitmasks.player.rawValue
        addChild(platform)
    }
    
    func makePlatform2(){
        let platform2 = SKSpriteNode(imageNamed: "Platform")
        
        platform2.position = CGPoint(x: size.width / 2, y: size.height / 4 + player.position.y)
        platform2.zPosition = 5
        platform2.setScale(CGFloat(2.5))
        platform2.physicsBody = SKPhysicsBody(rectangleOf: platform.size)
        platform2.physicsBody?.isDynamic = false
        platform2.physicsBody?.allowsRotation = false
        platform2.physicsBody?.affectedByGravity = false
        platform2.physicsBody?.categoryBitMask = bitmasks.player.rawValue
        platform2.physicsBody?.collisionBitMask = 0
        platform2.physicsBody?.contactTestBitMask = bitmasks.player.rawValue
        addChild(platform2)
    }
    
}
