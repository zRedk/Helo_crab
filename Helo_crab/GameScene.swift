import SpriteKit
import SwiftUI
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var lastPlayerYPosition: CGFloat = 0.0
    
    let background1 = SKSpriteNode(imageNamed: "background1")
    let background2 = SKSpriteNode(imageNamed: "background2")
    let background3 = SKSpriteNode(imageNamed: "background3")
    let background4 = SKSpriteNode(imageNamed: "background4")
    
    let backgroundNode = SKNode()
    var isTransitioningBackground = false

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
    var backgroundScrollSpeed: CGFloat = 0.5
    
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

        //BACKGROUND INIZIO
        
        // Aggiungi gli sfondi al nodo principale degli sfondi
        backgroundNode.addChild(background1)
        backgroundNode.addChild(background2)
        backgroundNode.addChild(background3)
        backgroundNode.addChild(background4)

        // Posiziona gli sfondi in sequenza
        background1.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background2.position = CGPoint(x: size.width / 2, y: background1.size.height)
        background3.position = CGPoint(x: size.width / 2, y: background1.size.height + background2.size.height)
        background4.position = CGPoint(x: size.width / 2, y: background1.size.height + background2.size.height + background3.size.height)

        // Aggiungi il nodo principale degli sfondi alla scena
        addChild(backgroundNode)
        
        //BACKGROUND FINE
        
        physicsWorld.contactDelegate = self
        
        ground.position = CGPoint(x: size.width / 2, y: background1.position.y - background1.size.height / 6)
        ground.zPosition = 5
        ground.setScale(10)
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.allowsRotation = false
        ground.physicsBody?.affectedByGravity = false
        addChild(ground)
        
        player.position = CGPoint(x: size.width / 2, y: ground.position.y + player.size.height / 4)
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
        cameraNode.position = CGPoint(x: size.width / 2, y: size.height / 6)
        
        
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
        
        let centerYThreshold: CGFloat = size.height / 4

        let isMovingUp = player.position.y > lastPlayerYPosition

            if isMovingUp && player.position.y > centerYThreshold {
                cameraNode.position.y = player.position.y
            }
            lastPlayerYPosition = player.position.y
        
        // Muovi il nodo principale degli sfondi per far scorrere gli sfondi verticalmente
        let yOffset = player.position.y - size.height / 4
        backgroundNode.position.y = -yOffset

        // Gestisci la transizione tra background1 e background2 solo se il punteggio è maggiore di 30
        if score >= 30 && !isTransitioningBackground && player.position.y > background2.position.y {
            isTransitioningBackground = true
            transitionToNextBackground()
        }
        // Gestisci la transizione tra background4 e il reset dell'infinito scrolling
             if player.position.y > background4.position.y {
                 resetInfiniteScrolling()
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
    
    //INIZOO
    func transitionToNextBackground() {
        let moveAction = SKAction.moveTo(y: background2.position.y - background1.size.height, duration: 1.0)
        let resetAction = SKAction.run {
            self.background1.position.y = 0
            self.isTransitioningBackground = false
        }
        let sequence = SKAction.sequence([moveAction, resetAction])
        background1.run(sequence)
    }
    
    
    func resetInfiniteScrolling() {
        let yOffset = background4.position.y + background4.size.height
        background4.position.y = background1.position.y - yOffset
    }
    //FINE
    

    
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
        case 0...30:
            physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        case 31...60:
            physicsWorld.gravity = CGVector(dx: 0, dy: -10.2)
        case 61...90:
            physicsWorld.gravity = CGVector(dx: 0, dy: -10.5)
        default:
            physicsWorld.gravity = CGVector(dx: 0, dy: -10.8)
        }
        
    }
    
    
    
}
