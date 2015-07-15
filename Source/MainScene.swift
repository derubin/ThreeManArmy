//
//  MainScene.swift
//  ThreeManArmy
//
//  Created by Daniel Rubin on 7/7/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class MainScene: CCNode, CCPhysicsCollisionDelegate {
    
    weak var hero: Hero!
    weak var basicEnemy: BasicEnemy!
    weak var gamePhysicsNode: CCPhysicsNode!
    var jumped = false//move to hero class later
    var shotCollision = 0
    var limitShots = 0
    var heroShots = 0
    var numTimes = 0
    
    func didLoadFromCCB() {
        userInteractionEnabled = true
        gamePhysicsNode.collisionDelegate = self
    }
    
    override func fixedUpdate(delta: CCTime) {
        if basicEnemy.detectHero(hero.position.y, xCor: hero.position.x, scale: -1) && basicEnemy.scaleX == -1 {
            generalShot(basicEnemy.position.x, yCor: basicEnemy.position.y, scale: -1)
        }
        else if basicEnemy.detectHero(hero.position.y, xCor: hero.position.x, scale: 1) && basicEnemy.scaleX == 1 {
            generalShot(basicEnemy.position.x, yCor: basicEnemy.position.y, scale: 1)
        }
            
        else {
            basicEnemy.move()
            limitShots++
            if hero.movementState == HeroMovementState.MovingRight {
                hero.position = CGPoint(x: (hero.position.x + 1), y: hero.position.y)
            }
            else if hero.movementState == HeroMovementState.MovingLeft {
                hero.position = CGPoint(x: (hero.position.x - 1), y: hero.position.y)
            }
        }
        heroShots++
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if (touch.locationInWorld().x >= 17 && touch.locationInWorld().y >= 7 && touch.locationInWorld().x <= 81 && touch.locationInWorld().y <= 47) {
            hero.movementState = HeroMovementState.MovingLeft
            hero.walkAnimate()
            hero.scaleX = -1
        }
        
        if (touch.locationInWorld().x >= 112 && touch.locationInWorld().y >= 7 && touch.locationInWorld().x <= 176 && touch.locationInWorld().y <= 47) {
            hero.movementState = HeroMovementState.MovingRight
            hero.walkAnimate()
            hero.scaleX = 1
        }
    }
    
    override func touchEnded(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if hero.movementState == HeroMovementState.MovingRight {
            hero.idleAnimate()
            hero.movementState = HeroMovementState.IdleRight
        }
        else if hero.movementState == HeroMovementState.MovingLeft {
            hero.idleAnimate()
            hero.movementState = HeroMovementState.IdleLeft
        }
    }
    
    func jump() {
        if self.jumped == false {
            self.hero.physicsBody.applyImpulse(CGPoint(x: 0, y: 75))
            self.jumped = true
            self.hero.jumpAnimate()
        }
    }

    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, falling: Hero!, ground: CCNode!) {
        if jumped == true && shotCollision == 0 {
            if hero.jump.visible == true {
                hero.idleAnimate()
            }
            jumped = false
        }
        shotCollision = 0
    }
    
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, basicEnemyCrash: BasicEnemy!, wall: CCNode!) {
        if basicEnemy.scaleX == -1 {
            basicEnemy.scaleX = 1
            basicEnemy.movementState = BasicEnemyState.MovingRight
        }
        else if basicEnemy.scaleX == 1 {
            basicEnemy.scaleX = -1
            basicEnemy.movementState = BasicEnemyState.MovingLeft
        }
    }
    
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, shot: CCParticleSystem!, wildcard: CCNode!) {
        self.gamePhysicsNode.removeChild(shot)
    }
    
    
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, basicEnemyCrash: BasicEnemy!, shot: CCParticleSystem!) {
        basicEnemyCrash.position.x = 200
        basicEnemyCrash.position.y = 125
    }
    
    func shoot() {
        if heroShots >= 30 {
            heroShots = 0
            shotCollision++
            hero.hasShot()
            let explosion = CCBReader.load("Shot") as! CCParticleSystem
            explosion.autoRemoveOnFinish = true
            explosion.position.y = (hero.position.y + 5)
            explosion.position.x = (hero.position.x + CGFloat(hero.shotMoveScale))
            gamePhysicsNode.addChild(explosion)
            explosion.physicsBody.applyImpulse(CGPoint(x: hero.shotImpulseScale, y: 0))
            shotCollision++
        }
    }
    
    func generalShot(xCor: CGFloat, yCor: CGFloat, scale: Int) {
        if limitShots >= 28 {
            limitShots = 0
            let explosionEnemy = CCBReader.load("Shot") as! CCParticleSystem
            explosionEnemy.autoRemoveOnFinish = true
            explosionEnemy.position.y = (yCor + 5)
            explosionEnemy.position.x = (xCor + CGFloat(basicEnemy.shotMoveScale))
            gamePhysicsNode.addChild(explosionEnemy)
            explosionEnemy.physicsBody.applyImpulse(CGPoint(x: basicEnemy.shotImpulseScale, y: 0))
        }
        limitShots++
    }
}
