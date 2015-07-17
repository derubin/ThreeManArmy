//
//  Hero.swift
//  ThreeManArmy
//
//  Created by Daniel Rubin on 7/10/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

enum HeroMovementState {
    case IdleRight
    case IdleLeft
    case MovingRight
    case MovingLeft
}


class Hero: CCSprite {
    
    var movementState: HeroMovementState = .IdleRight {
        didSet {
            if movementState == .IdleRight || movementState == .MovingRight {
                shotMoveScale = 5
                shotImpulseScale = 20
            }
            if movementState == .IdleLeft || movementState == .MovingLeft {
                shotMoveScale = -8
                shotImpulseScale = -20
            }
        }
    }
    var isShooting: Bool = false
    var isJumping: Bool = false
    
    weak var idle: CCNode!
    weak var jump: CCNode!
    weak var shoot: CCNode!
    weak var walk: CCNode!
    weak var walkShoot: CCNode!
    weak var die: CCNode!
    weak var crouch: CCNode!
    weak var crouchShoot: CCNode!
    
    var shotMoveScale = 0
    var shotImpulseScale = 0
    var jumped = false
    var movingRight = false
    var movingLeft = false
    
    func hasShot() {
        idle.visible = false
        walk.visible = false
        jump.visible = false
        shoot.visible = true
        animationManager.runAnimationsForSequenceNamed("Shoot")
    }
    
    func idleAnimate() {
        walk.visible = false
        shoot.visible = false
        jump.visible = false
        idle.visible = true
        animationManager.runAnimationsForSequenceNamed("Idle")
    }
    
    func walkAnimate() {
        idle.visible = false
        shoot.visible = false
        jump.visible = false
        walk.visible = true
        animationManager.runAnimationsForSequenceNamed("Walk")
    }
    
    func jumpAnimate() {
        idle.visible = false
        shoot.visible = false
        walk.visible = false
        jump.visible = true
        animationManager.runAnimationsForSequenceNamed("Jump")
    }
    
    func heroJump() {
        if self.jumped == false {
            self.physicsBody.applyImpulse(CGPoint(x: 0, y: 75))
            self.jumped = true
            self.jumpAnimate()
        }
    }
}