import SpriteKit
import SwiftUI
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let background1 = SKSpriteNode(imageNamed: "background1")
    let background2 = SKSpriteNode(imageNamed: "background2")
    let background3 = SKSpriteNode(imageNamed: "background3")
    let background4 = SKSpriteNode(imageNamed: "background4")
    

    let player = SKSpriteNode(imageNamed: "crab80x80")
    let ground = SKSpriteNode(imageNamed: "Ground")
    let cameraNode = SKCameraNode()
    let playerOverTheLine = SKSpriteNode(color: .red, size: CGSize(width: 1000, height: 7))
    var firstTouch = false
    let scoreLabel = SKLabelNode()
    let bestScoreLabel = SKLabelNode()
    let defaults = UserDefaults.standard
    
    var score: Int = 0
    var bestScore: Int = 0
    
    var backgroundLayerHeight: CGFloat = 0.0
    var backgroundScrollSpeed: CGFloat = 2.0
    
    var jumpCount = 0
    var isBackground4Infinite = false
    
    
    enum bitmasks: UInt32 {
        case player = 0b1
        case platform = 0b10
        case playerOverTheLine
    }
    
    var lastGeneratedPlatformY: CGFloat = 0.0
    
    override func didMove(to view: SKView) {
        self.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.anchorPoint = .zero
        
        background1.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background1.zPosition = 0
        addChild(background1)
        
        background2.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background2.zPosition = -1
        addChild(background2)
        
        background3.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background3.zPosition = -2
        addChild(background3)
        
        background4.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background4.zPosition = -2
        addChild(background4)
        
        backgroundLayerHeight = player.position.y
        
        // Imposta l'altezza iniziale dei background oltre il quale diventano visibili
        background2.position.y = size.height
        background3.position.y = size.height * 2
        background4.position.y = size.height * 3
        
        physicsWorld.contactDelegate = self
        
        ground.position = CGPoint(x: size.width / 2, y: -280)
        ground.zPosition = 5
        ground.setScale(10)
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.allowsRotation = false
        ground.physicsBody?.affectedByGravity = false
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
        player.physicsBody?.contactTestBitMask = bitmasks.platform.rawValue | bitmasks.playerOverTheLine.rawValue
        
        
        self.camera = cameraNode
        addChild(cameraNode)
        cameraNode.position = player.position
        addChild(player)
        
        //Linea per il game over
        playerOverTheLine.position = CGPoint(x: player.position.x, y: player.position.y - 200)
        playerOverTheLine.zPosition = -10
        playerOverTheLine.physicsBody = SKPhysicsBody(rectangleOf: playerOverTheLine.size)
        playerOverTheLine.physicsBody?.affectedByGravity = false
        playerOverTheLine.physicsBody?.allowsRotation = false
        playerOverTheLine.physicsBody?.categoryBitMask = bitmasks.playerOverTheLine.rawValue
        playerOverTheLine.physicsBody?.contactTestBitMask = bitmasks.platform.rawValue | bitmasks.player.rawValue
        addChild(playerOverTheLine)
        
        scoreLabel.position.x = 70
        scoreLabel.zPosition = 20
        scoreLabel.fontSize = 22
        scoreLabel.fontName = "SF Pro"
        scoreLabel.fontColor = .black
        scoreLabel.text = "Score: \(score)"
        addChild(scoreLabel)
        
        bestScore = defaults.integer(forKey: "best")
        bestScoreLabel.position.x = 300
        bestScoreLabel.zPosition = 20
        bestScoreLabel.fontSize = 22
        bestScoreLabel.fontName = "SF Pro"
        bestScoreLabel.fontColor = .black
        bestScoreLabel.text = "Best Score: \(bestScore)"
        addChild(bestScoreLabel)
        
        
        
        // Imposta l'ultima piattaforma generata inizialmente
        lastGeneratedPlatformY = player.position.y
        
        // Genera le prime 6 piattaforme
        makePlatform()
        
        
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        cameraNode.position.y = player.position.y
        
        // Aggiorna la posizione del background in base all'altezza del layer di sfondo
        background1.position.y = backgroundLayerHeight
        background2.position.y = backgroundLayerHeight + size.height
        background3.position.y = backgroundLayerHeight + size.height * 2
        background4.position.y = backgroundLayerHeight + size.height * 3
        
        // Muovi lo sfondo verso l'alto solo se il giocatore si muove
        if player.position.y > backgroundLayerHeight {
            backgroundLayerHeight += backgroundScrollSpeed
        }
        
        // Se il giocatore ha raggiunto background4, rendilo infinito e mostra un nuovo background
        if player.position.y > background4.position.y && !isBackground4Infinite {
            background4.position.y += background4.size.height
            isBackground4Infinite = true
            showNewBackground()
        }
        
        if player.physicsBody!.velocity.dy > 0 {
            playerOverTheLine.position.y = player.position.y - 500 //Passato questo si rimuove la piattaforma
        }
        
        // Se il giocatore ha sbloccato una nuova parte dello schermo, genera una nuova piattaforma
        if player.position.y > lastGeneratedPlatformY - size.height {
            generateNewPlatform()
        }
        
        scoreLabel.position.y = player.position.y + 300
        
        bestScoreLabel.position.y = player.position.y + 300
        
        // Aumenta la gravità
        increaseDifficulty()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactA: SKPhysicsBody
        let contactB: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            contactA = contact.bodyA //player
            contactB = contact.bodyB //platform
        } else {
            contactA = contact.bodyB //player
            contactB = contact.bodyA //platform
        }
        //Questo serve a rimuovere la piattaforma
        if contactA.categoryBitMask == bitmasks.platform.rawValue && contactB.categoryBitMask == bitmasks.playerOverTheLine.rawValue {
            contactA.node?.removeFromParent()
        }
        
        if contactA.categoryBitMask == bitmasks.player.rawValue && contactB.categoryBitMask == bitmasks.platform.rawValue {
            // Aumenta la dimensione del salto del giocatore
            if player.physicsBody!.velocity.dy < 0 {
                player.physicsBody?.velocity = CGVector(dx: player.physicsBody!.velocity.dx, dy: 1000)
                contactB.node?.removeFromParent()
                
                
                addScore()
            }
        }
        
        if contactA.categoryBitMask == bitmasks.player.rawValue && contactB.categoryBitMask == bitmasks.playerOverTheLine.rawValue {
            gameOver()
        }
    }
    
    func showNewBackground() {
        jumpCount += 1
        
        // Verifica quale background mostrare in base al numero totale di salti
        if jumpCount >= 30 {
            addChild(background2)
        }
        
        if jumpCount >= 70 {
            addChild(background3)
        }
        
        if jumpCount >= 120 {
            addChild(background4)
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
        let platform = SKSpriteNode(imageNamed: "Platform")
        platform.position = CGPoint(x: GKRandomDistribution(lowestValue: Int(size.width * 0.1), highestValue: Int(size.width * 0.9)).nextInt(), y: GKRandomDistribution(lowestValue: 70, highestValue: 150).nextInt() + Int(player.position.y))
        platform.setScale(2)
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
    
    func generateNewPlatform() {
        // Riduci lo spawn rate delle piattaforme
        if arc4random_uniform(3) == 0 {
            return
        }
        
        let minY = Int(lastGeneratedPlatformY) + 270
        let maxY = minY + 10
        let platform = generatePlatform(minY: minY, maxY: maxY)
        lastGeneratedPlatformY = platform.position.y
        addChild(platform)
    }
    
    func generatePlatform(minY: Int, maxY: Int) -> SKSpriteNode {
            let platform = SKSpriteNode(imageNamed: "Platform")
            
            // Aggiungi una probabilità di generare piattaforme trappola in base allo score
            let trapPlatformProbability = CGFloat(score) / 100.0 // Modifica il valore 100 come preferisci
            let isTrapPlatform = CGFloat.random(in: 0.0...1.0) < trapPlatformProbability
            
            // Verifica se è una piattaforma trappola e aggiungi il movimento da destra a sinistra
            if isTrapPlatform {
                platform.texture = SKTexture(imageNamed: "Platform") // Usa l'immagine della piattaforma normale
                let moveLeft = SKAction.moveTo(x: 400, duration: 2.0) // Imposta la velocità e la direzione del movimento
                let moveRight = SKAction.moveTo(x: 0, duration: 2.0)
                let moveSequence = SKAction.sequence([moveLeft, moveRight])
                let moveForever = SKAction.repeatForever(moveSequence)
                platform.run(moveForever)
            } else {
                platform.texture = SKTexture(imageNamed: "Platform")
            }
            
            // Imposta il posizionamento della piattaforma
            let platformX = GKRandomDistribution(lowestValue: Int(size.width * 0.1), highestValue: Int(size.width * 0.9)).nextInt()
            let platformY = isTrapPlatform ? maxY - 50 : GKRandomDistribution(lowestValue: minY, highestValue: maxY).nextInt()
            platform.position = CGPoint(x: platformX, y: platformY)
            
            // Imposta la categoria della piattaforma
            platform.zPosition = 5
            platform.setScale(2)
            platform.physicsBody = SKPhysicsBody(rectangleOf: platform.size)
            platform.physicsBody?.isDynamic = false
            platform.physicsBody?.allowsRotation = false
            platform.physicsBody?.affectedByGravity = false
            platform.physicsBody?.categoryBitMask = bitmasks.platform.rawValue
            platform.physicsBody?.collisionBitMask = 0
            platform.physicsBody?.contactTestBitMask = bitmasks.player.rawValue
            
            return platform
        }
    
    func gameOver() {
        
        let gameOverScene = gameOverScene(size: size.self)
        let transition = SKTransition.crossFade(withDuration: 0.5)
        
        view?.presentScene(gameOverScene, transition: transition)
        
        if score > bestScore {
            bestScore = score
            defaults.set(bestScore, forKey: "best")
        }
    }
    
    func addScore() {
        score += 1
        scoreLabel.text = "Score: \(score)"
    }
    
    func increaseDifficulty() {
        switch score {
        case 0...5:
            physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        case 6...10:
            physicsWorld.gravity = CGVector(dx: 0, dy: -10.4)
        case 11...15:
            physicsWorld.gravity = CGVector(dx: 0, dy: -10.6)
        default:
            physicsWorld.gravity = CGVector(dx: 0, dy: -10.9)
        }
        print("\(String(describing: player.scene?.physicsWorld.gravity.dy))")
    }
    
    
    
}
