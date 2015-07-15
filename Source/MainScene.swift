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
    weak var enemyNode: CCNode!//All enemies added onto this node
    var jumped = true//move to hero class later
    var shotCollision = 0 //Not sure, currently commented out.
    var limitShots = 0//limits enemies to shooting once per 28 frames
    var heroShots = 30//limits hero to shooting once per 30 frames (one sec)
    var enemyArray: [BasicEnemy] = []//array of BasicEnemy's in addEnemy(xCor, yCor)
    var numBasicEnemies = 0//keeps track of num of enemies.  Add one as starts at 0
    
    func didLoadFromCCB() {
        numBasicEnemies--
        userInteractionEnabled = true
        gamePhysicsNode.collisionDelegate = self
        addEnemy(400, yCor: 150)
    }
    
    override func fixedUpdate(delta: CCTime) {
        for index in 0...numBasicEnemies {
            if enemyArray[index].detectHero(hero.position.y, xCor: hero.position.x, scale: -1) && enemyArray[index].scaleX == -1 && limitShots >= 28 {
                basicEnemyShot(enemyArray[index])
                limitShots = 0
            }
            else if enemyArray[index].detectHero(hero.position.y, xCor: hero.position.x, scale: 1) && enemyArray[index].scaleX == 1 && limitShots >= 28 {
                basicEnemyShot(enemyArray[index])
                limitShots = 0
            }
            else {
                enemyArray[index].move()
            }
        }
        if hero.movementState == HeroMovementState.MovingRight {
            hero.position = CGPoint(x: (hero.position.x + 1), y: hero.position.y)
        }
        else if hero.movementState == HeroMovementState.MovingLeft {
            hero.position = CGPoint(x: (hero.position.x - 1), y: hero.position.y)
        }
        heroShots++
        limitShots++
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
        if jumped == true/* && shotCollision == 0*/ {
            if hero.jump.visible == true {
                hero.idleAnimate()
            }
            jumped = false
        }
//        shotCollision = 0
    }
    
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, basicEnemyCrash: BasicEnemy!, wall: CCNode!) {
        if basicEnemyCrash.scaleX == -1 {
            basicEnemyCrash.scaleX = 1
            basicEnemyCrash.movementState = BasicEnemyState.MovingRight
        }
        else if basicEnemyCrash.scaleX == 1 {
            basicEnemyCrash.scaleX = -1
            basicEnemyCrash.movementState = BasicEnemyState.MovingLeft
        }
    }
    
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, shot: CCParticleSystem!, wildcard: CCNode!) {
        self.gamePhysicsNode.removeChild(shot)
    }
    
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, basicEnemyCrash name1: BasicEnemy!, basicEnemyCrash: BasicEnemy!) {
        if basicEnemyCrash.scaleX == -1 {
            basicEnemyCrash.scaleX = 1
            basicEnemyCrash.movementState = BasicEnemyState.MovingRight
        }
        else if basicEnemyCrash.scaleX == 1 {
            basicEnemyCrash.scaleX = -1
            basicEnemyCrash.movementState = BasicEnemyState.MovingLeft
        }
    }
    
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, basicEnemyCrash: BasicEnemy!, shot: CCParticleSystem!) {
        enemyNode.removeChild(basicEnemyCrash)
    }
    
    func shoot() {
        if heroShots >= 30 {
            heroShots = 0
//            shotCollision++
            hero.hasShot()
            let explosion = CCBReader.load("Shot") as! CCParticleSystem
            explosion.autoRemoveOnFinish = true
            explosion.position.y = (hero.position.y + 5)
            explosion.position.x = (hero.position.x + CGFloat(hero.shotMoveScale))
            gamePhysicsNode.addChild(explosion)
            explosion.physicsBody.applyImpulse(CGPoint(x: hero.shotImpulseScale, y: 0))
//            shotCollision++
        }
    }
    
    func basicEnemyShot(enemyPos: BasicEnemy) {
        let explosionEnemy = CCBReader.load("Shot") as! CCParticleSystem
        explosionEnemy.autoRemoveOnFinish = true
        explosionEnemy.position.y = (enemyPos.position.y + 5)
        explosionEnemy.position.x = (enemyPos.position.x + CGFloat(enemyPos.shotMoveScale))
        gamePhysicsNode.addChild(explosionEnemy)
        explosionEnemy.physicsBody.applyImpulse(CGPoint(x: enemyPos.shotImpulseScale, y: 0))
    }
    
    func addEnemy(xCor: CGFloat, yCor: CGFloat) {
        let temporaryBasicEnemy = CCBReader.load("BasicEnemy") as! BasicEnemy
        enemyArray.append(temporaryBasicEnemy)
        temporaryBasicEnemy.position = CGPoint(x: xCor, y: yCor)
        enemyNode.addChild(temporaryBasicEnemy)
        numBasicEnemies++
    }
}