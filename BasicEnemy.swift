//
//  BasicEnemy.swift
//  ThreeManArmy
//
//  Created by Daniel Rubin on 7/13/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

enum BasicEnemyState {
    case MovingRight
    case MovingLeft
}

class BasicEnemy: CCSprite {
    
    var movementState: BasicEnemyState = .MovingLeft {
        didSet {
            if movementState == .MovingRight {
                shotMoveScale = 5
                shotImpulseScale = 20
            }
            if movementState == .MovingLeft {
                shotMoveScale = -5
                shotImpulseScale = -20
            }
        }
    }
    
    var shotMoveScale = 0
    var shotImpulseScale = 0
    weak var walk: CCNode!
    weak var shootRight: CCNode!
    weak var shootLeft: CCNode!
    var isShooting = false
    
    func shootBowRight() {
        walk.visible = false
        shootLeft.visible = false
        shootRight.visible = true
        isShooting = true
    }
    
    func shootBowLeft() {
        walk.visible = false
        shootRight.visible = false
        shootLeft.visible = true
        isShooting = true
    }
    
    func detectHero(yCor: CGFloat, xCor: CGFloat, scale: Int) -> Bool {
        if self.position.y >= (yCor - 10) && self.position.y <= (yCor + 10) {
            var difference = abs(self.position.x - xCor)
            if self.position.x >= xCor && scale == -1 && difference <= 648 {
                return true
            }
            else if self.position.x < xCor && scale == 1 && difference <= 648 {
                return true
            }
            else {
                return false
            }
        }
        else {
            return false
        }
    }
    
    func move() {
        if isShooting == true {
            isShooting = false
            shootRight.visible = false
            shootLeft.visible = false
            walk.visible = true
        }
        if self.scaleX == 1 {
            self.position = CGPoint(x: (self.position.x + 1), y: self.position.y)
        }
        else if self.scaleX == -1 {
            self.position = CGPoint(x: (self.position.x - 1), y: self.position.y)
        }
    }
}