//
//  Disc.swift
//  ttPong
//
//  Created by Raul Costa Junior on 16.07.20.
//  Copyright © 2020 Raul Costa Junior. All rights reserved.
//

import Foundation
import SpriteKit

// TODO: Remove this class and incorporate all its functionality into the DiscSprite class

/**
  The physical disc - an agregate of the disc sprite and its physical body,
  with the corresponding physical properties.
 */
class Disc {
    
    init(with sprite: DiscSprite) {
        _sprite = sprite
        _paused = false
        _sprite.physicsBody =
            SKPhysicsBody.init(circleOfRadius: _sprite.size.width/2.0)
        _sprite.physicsBody!.isDynamic = true
        _sprite.physicsBody!.linearDamping = 0.0  // Disc is frictionless!
        _sprite.physicsBody!.velocity = CGVector(dx: 0.0, dy: 0.0)
    }
    
    func pauseDisc() {
        guard !_paused else {
            print("pauseDisc called for a disc that is already paused!")
            return
        }
        _paused = true
        _resumeVelocity = _sprite.physicsBody!.velocity
        _sprite.physicsBody!.velocity = CGVector(dx: 0.0, dy: 0.0)
    }
    
    func resumeDisc() {
        guard _paused else {
            print("resumeDisc called with no corresponding previous pauseDisc!")
            return
        }
        assert(_resumeVelocity != nil,
               "A disc that has already been paused must have a defined _resumeVelocity")
        _sprite.physicsBody!.velocity = _resumeVelocity!
        _paused = false
    }
    
    var velocity: CGVector {
        get {
            return _sprite.physicsBody!.velocity
        }
        
        set {
            guard !_paused else {
                print("Disc velocity cannot be set while disc is paused!")
                return
            }
            _sprite.physicsBody!.velocity = newValue
        }
    }
    
    var sprite: DiscSprite { return _sprite }
    
    private var _paused: Bool
    private var _sprite: DiscSprite
    private var _resumeVelocity: CGVector?
    
}
