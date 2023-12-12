//
//  gameOverScene.swift
//  Helo_crab
//
//  Created by Salvatore Flauto on 11/12/23.
//

import Foundation
import SpriteKit

class gameOverScene: SKScene {
    let background = SKSpriteNode(imageNamed: "stillcrab")
    let gameOver = SKSpriteNode(imageNamed: "gameover")
    
    override func didMove(to view: SKView) {
        
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(background)
        
        gameOver.position = CGPoint(x: size.width / 2, y: size.width / 2)
        gameOver.setScale(3.2)
        gameOver.zPosition = -1
        addChild(gameOver)
        
        let tapLabel = SKLabelNode()
        tapLabel.fontName = "SF Pro"
        tapLabel.position = CGPoint(x: size.width / 2, y: size.height / 4)
        tapLabel.text = "Tap to restart"
        tapLabel.fontSize = 46
        tapLabel.fontColor = .black
        
        let outAction = SKAction.fadeOut(withDuration: 0.5)
        let inAction = SKAction.fadeIn(withDuration: 0.5)
        let sequence = SKAction.sequence([outAction, inAction])
        
        tapLabel.run(SKAction.repeatForever(sequence))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let gameScene = GameScene(size: size.self)
        let transition = SKTransition.flipVertical(withDuration: 0.5)
        
        view?.presentScene(gameScene, transition: transition)
    }
}
