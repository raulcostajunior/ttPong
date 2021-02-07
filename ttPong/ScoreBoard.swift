//
//  ScoreBoard.swift
//  ttPong
//
//  Created by Raul Costa Junior on 14.06.20.
//  Copyright © 2020 Raul Costa Junior. All rights reserved.
//

import Foundation

/**
 Game score board - keeps track of current game score, current player's record and global record.
 */
    
class ScoreBoard {
    
    private var _score: Int64 = 0
    // Negative values are used to indicate that high scores and player rank haven't being initialized
    // yet. Those values depend on responses for network requests.
    private var _playerHighScore: Int64 = -1
    private var _globalHighScore: Int64 = -1
    private var _playerRank: Int64 = -1
    private var _newPlayerRecord = false
    
    var score:Int64 { return _score }
    var playerHighScore:Int64 { return _playerHighScore }
    var globalHighScore: Int64 { return _globalHighScore }
    var playerRank: Int64 { return _playerRank }
    var isNewPlayerRecord: Bool { return _newPlayerRecord }
    
    func setHighScores(playerHighScore: Int64, globalHighScore: Int64, playerRank: Int64) {
        guard globalHighScore >= playerHighScore else {
            print("@ScoreBoard.setHighScores: playerHighScore '\(playerHighScore) cannot be greater than globalHighScore '\(globalHighScore)'!")
            return
        }
        guard playerHighScore >= 0 else {
            print("@ScoreBoard.setHighScores: playerHighScore '\(playerHighScore) cannot be negative!")
            return
        }
        _playerHighScore = playerHighScore
        _playerRank = playerRank
        _globalHighScore = globalHighScore
        _newPlayerRecord = _score > _playerHighScore
    }
      
    func increaseScore(by increment:Int64) {
        _score += increment
        if _playerHighScore >= 0 && _score > _playerHighScore {
            _newPlayerRecord = true
            _playerHighScore = _score
        }
    }
    
    func resetScore() {
        _score = 0
        _newPlayerRecord = false
    }
    
}
