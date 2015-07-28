//
//  HeavyTerror.swift
//  ThreeManArmy
//
//  Created by Daniel Rubin on 7/13/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

enum BossState {
    case Idle
    case Shooting
    case Blocking
}

class HeavyTerror: CCSprite {
    
    weak var idle: CCNode!
    weak var walk: CCNode!
    weak var aimA: CCNode!
    
    var isClose = true
    
    func aim() {
        aimA.visible = true
        walk.visible = false
        idle.visible = false
        animationManager.runAnimationsForSequenceNamed("AimA")
    }
    
    func idleWait() {
        idle.visible = true
        walk.visible = false
        aimA.visible = false
        animationManager.runAnimationsForSequenceNamed("Idle")
    }
}