import SpriteKit
import SwiftUI
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let background = SKSpriteNode(imageNamed: "background1")
    let player = SKSpriteNode(imageNamed: "crab80x80")
    let ground = SKSpriteNode(imageNamed: "Ground")
    let cameraNode = SKCameraNode()
    
    var firstTouch = false
    
    enum bitmasks: UInt32 {
        case player = 0b1
        case platform = 0b10
    }
    
    var lastGeneratedPlatformY: CGFloat = 0.0
    
    override func didMove(to view: SKView) {
        self.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.anchorPoint = .zero
        
        background.position = CGPoint(x: size.width / 2, y: 500)
        background.setScale(2)
        background.zPosition = 1
        addChild(background)
        
        physicsWorld.contactDelegate = self
        
        ground.position = CGPoint(x: size.width / 2, y: -45)
        ground.zPosition = 5
        ground.setScale(10)
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.allowsRotation = false
        ground.physicsBody?.affectedByGravity = false
        ground.physicsBody?.categoryBitMask = bitmasks.platform.rawValue
        ground.physicsBody?.collisionBitMask = 0
        ground.physicsBody?.contactTestBitMask = bitmasks.player.rawValue
        addChild(ground)
        
        player.position = CGPoint(x: size.width / 2, y: size.height / 7)
        player.zPosition = 10
        player.setScale(0.5)
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.height / 2)
        player.physicsBody?.isDynamic = false
        player.physicsBody?.restitution = 1
        player.physicsBody?.friction = 0
        player.physicsBody?.angularDamping = 0
        player.physicsBody?.categoryBitMask = bitmasks.player.rawValue
        player.physicsBody?.collisionBitMask = 0
        player.physicsBody?.contactTestBitMask = bitmasks.platform.rawValue
        
        self.camera = cameraNode
        addChild(cameraNode)
        cameraNode.position = player.position
        addChild(player)
        
        // Imposta l'ultima piattaforma generata inizialmente
        lastGeneratedPlatformY = player.position.y
        
        // Genera le prime 6 piattaforme
        makePlatform()
//        makePlatform2()
//        makePlatform3()
//        makePlatform4()
//        makePlatform5()
//        makePlatform6()
    }
    
    override func update(_ currentTime: TimeInterval) {
        cameraNode.position.y = player.position.y
        
        let yOffset = player.position.y - size.height / 4
        background.position.y = yOffset
        // Se il giocatore ha sbloccato una nuova parte dello schermo, genera una nuova piattaforma
        if player.position.y > lastGeneratedPlatformY - size.height {
            generateNewPlatform()
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactA: SKPhysicsBody
        let contactB: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            contactA = contact.bodyA
            contactB = contact.bodyB
        } else {
            contactA = contact.bodyB
            contactB = contact.bodyA
        }
        if contactA.categoryBitMask == bitmasks.player.rawValue && contactB.categoryBitMask == bitmasks.platform.rawValue {
            // Aumenta la dimensione del salto del giocatore
            if player.physicsBody!.velocity.dy < 0 {
                player.physicsBody?.velocity = CGVector(dx: player.physicsBody!.velocity.dx, dy: 1000)
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
        
        if firstTouch == false {
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 50))
        }
        
        firstTouch = true
    }
    
    func makePlatform() {
        let platform = SKSpriteNode(imageNamed: "abyssplatform")
        platform.position = CGPoint(x: GKRandomDistribution(lowestValue: Int(size.width * 0.1), highestValue: Int(size.width * 0.9)).nextInt(), y: GKRandomDistribution(lowestValue: 70, highestValue: 150).nextInt() + Int(player.position.y))
        platform.setScale(1)
        platform.zPosition = 5
        platform.physicsBody = SKPhysicsBody(rectangleOf: platform.size)
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.allowsRotation = false
        platform.physicsBody?.affectedByGravity = false
        platform.physicsBody?.categoryBitMask = bitmasks.platform.rawValue
        platform.physicsBody?.collisionBitMask = 0
        platform.physicsBody?.contactTestBitMask = bitmasks.player.rawValue
        addChild(platform)
    }
    
    func makePlatform2() {
        let platform = SKSpriteNode(imageNamed: "abyssplatform")
        platform.position = CGPoint(x: GKRandomDistribution(lowestValue: Int(size.width * 0.1), highestValue: Int(size.width * 0.9)).nextInt(), y: GKRandomDistribution(lowestValue: 200, highestValue: 300).nextInt() + Int(player.position.y))
        platform.zPosition = 5
        platform.setScale(1)
        platform.physicsBody = SKPhysicsBody(rectangleOf: platform.size)
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.allowsRotation = false
        platform.physicsBody?.affectedByGravity = false
        platform.physicsBody?.categoryBitMask = bitmasks.platform.rawValue
        platform.physicsBody?.collisionBitMask = 0
        platform.physicsBody?.contactTestBitMask = bitmasks.player.rawValue
        addChild(platform)
    }
    
    func makePlatform3() {
        let platform = generatePlatform(minY: Int(player.position.y) + 350, maxY: Int(player.position.y) + 450)
        addChild(platform)
    }
    
    func makePlatform4() {
        let platform = generatePlatform(minY: Int(player.position.y) + 500, maxY: Int(player.position.y) + 600)
        addChild(platform)
    }
    
    func makePlatform5() {
        let platform = generatePlatform(minY: Int(player.position.y) + 650, maxY: Int(player.position.y) + 750)
        addChild(platform)
    }
    
    func makePlatform6() {
        let platform = generatePlatform(minY: Int(player.position.y) + 700, maxY: Int(player.position.y) + 900)
        addChild(platform)
    }
    
    func generateNewPlatform() {
        // Riduci lo spawn rate delle piattaforme
        if arc4random_uniform(3) == 0 {
            return
        }
        
        let minY = Int(lastGeneratedPlatformY) + 200
        let maxY = minY + 100
        let platform = generatePlatform(minY: minY, maxY: maxY)
        lastGeneratedPlatformY = platform.position.y
        addChild(platform)
    }
    
    func generatePlatform(minY: Int, maxY: Int) -> SKSpriteNode {
        let platform = SKSpriteNode(imageNamed: "abyssplatform")
        platform.position = CGPoint(x: GKRandomDistribution(lowestValue: Int(size.width * 0.1), highestValue: Int(size.width * 0.9)).nextInt(), y: GKRandomDistribution(lowestValue: minY, highestValue: maxY).nextInt())
        platform.zPosition = 5
        platform.setScale(1)
        platform.physicsBody = SKPhysicsBody(rectangleOf: platform.size)
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.allowsRotation = false
        platform.physicsBody?.affectedByGravity = false
        platform.physicsBody?.categoryBitMask = bitmasks.platform.rawValue
        platform.physicsBody?.collisionBitMask = 0
        platform.physicsBody?.contactTestBitMask = bitmasks.player.rawValue
        return platform
    }
}
