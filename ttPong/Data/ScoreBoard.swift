//
//  ScoreBoard.swift
//  ttPong
//
//  Created by Raul Costa Junior on 14.06.20.
//  Copyright © 2020 Raul Costa Junior. All rights reserved.
//

import Foundation

/**
 Game score board.

 For now, this does only contains the player's self assigned
 alias - just like old school arcade machines.
 */
    
class ScoreBoard {
    
    private var _score = 0
    private var _highScore = 0
    private var _newRecord = false
    
    var score:Int { return _score }
    var highScore:Int { return _highScore }
    var isNewRecord:Bool { return _newRecord }
    
    init(highScore: Int) {
        _score = 0
        _highScore = highScore
        _newRecord = false
    }
    
    func increaseScore(by increment:Int) {
        _score += increment
        if _score > _highScore {
            _newRecord = true
            _highScore = _score
        }
    }
    
    func resetScore() {
        _score = 0
        _newRecord = false
    }
    
}

