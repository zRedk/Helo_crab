//
//  Model.swift
//  Helo_crab
//
//  Created by Salvatore Flauto on 09/12/23.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Leaderboard {
    var bestScore: Int?
    
    init(bestScore: Int?){
        self.bestScore = bestScore
    }
}
