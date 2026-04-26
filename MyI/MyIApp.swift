//
//  MyIApp.swift
//  MyI
//
//  Created by Tom Choi on 4/26/26.
//

import Clients
import SwiftUI

@main
struct MyIApp: App {
    init() {
        AppBootstrap.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    _ = AppBootstrap.handle(url: url)
                }
        }
    }
}
