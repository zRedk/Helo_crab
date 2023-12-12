//
//  Helo_crabApp.swift
//  Helo_crab
//
//  Created by Federica Mosca on 07/12/23.
//

import SwiftUI
//import SwiftData

//let ContainerConfiguration = ModelConfiguration(isStoredInMemoryOnly: false, allowsSave: true)
//
//let bestScoreContainer: ModelContainer = {
//    let schema = Schema([Leaderboard.self])
//    let container = try! ModelContainer(for: schema, configurations: ContainerConfiguration)
//    return container
//}()


@main
struct Helo_crabApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
//        .modelContainer(bestScoreContainer)
    }
}
