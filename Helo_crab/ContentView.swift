//
//  ContentView.swift
//  Helo_crab
//
//  Created by Federica Mosca on 07/12/23.
//

import SwiftUI
import SpriteKit

class StartScene: SKScene{
    
    override func didMove(to view: SKView) {
        self.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        scene?.scaleMode = .aspectFill
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let lokation = touch.location(in: self)
            let starNode = atPoint(lokation)
            
            if starNode.name == "startButton" {
                let game = GameScene(size: self.size)
                let transition = SKTransition.flipVertical(withDuration: 0.5)
                
                self.view?.presentScene(game, transition: transition)
            }
        }
    }
}

struct ContentView: View {
    let startScene = StartScene(fileNamed: "StartScene")!
    
    var body: some View {
        SpriteView(scene: startScene)
            .ignoresSafeArea()
    }
    
}

#Preview {
    ContentView()
}
