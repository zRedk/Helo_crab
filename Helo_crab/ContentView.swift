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
