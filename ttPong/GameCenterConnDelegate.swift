//
//  GameCenterConnDelegate.swift
//  ttPong
//
//  Created by Raul Costa Junior on 20.09.21.
//  Copyright © 2021 Raul Costa Junior. All rights reserved.
//

import Foundation
import GameKit

/**
 A delegate with methods to be called whenever a player
 connects or disconnects from a GameCenter session.
 */
public protocol GameCenterConnDelegate {
    func GameCenterPlayerConnected(playerId: String)
    func GameCenterPlayerDisconnected(playerId: String)
}
