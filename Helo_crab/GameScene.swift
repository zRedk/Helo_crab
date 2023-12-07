//
//  GameScene.swift
//  Helo_crab
//
//  Created by Federica Mosca on 07/12/23.
//

import Foundation
import SpriteKit

class GameScene: SKScene{
    
    let background = SKSpriteNode(imageNamed: "Background")
    let player = SKSpriteNode(imageNamed: "Image")
    let ground = SKSpriteNode(imageNamed: "Platform")
    let platform = SKSpriteNode(imageNamed: "Platform")
    
    override func didMove(to view: SKView) {
        self.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        self.anchorPoint = .zero
        
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = 1
        background.setScale(2.5)
        addChild (background)
        
        ground.position = CGPoint(x: size.width / 2, y: -150)
        ground.zPosition = 5
        ground.setScale (15)
        addChild(ground)
        
        player.position = CGPoint(x: size.width / 2, y: size.height / 8)
        player.zPosition = 10
        player.setScale(3.5)
        addChild (player)
        
    }
    
    
}
