//
//  MainScene.swift
//  ThreeManArmy
//
//  Created by Daniel Rubin on 7/7/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//
//  Note, gameOver creates new scenes, have to delete them as well - memory issues
//  Separation for background is 850, starts at 750, for scenes: 756

import Foundation

class MainScene: CCNode, CCPhysicsCollisionDelegate {
    
    weak var hero: Hero!
    weak var basicEnemy: BasicEnemy!
    weak var gamePhysicsNode: CCPhysicsNode!
    weak var enemyNode: CCNode!//All enemies added onto this node
    weak var contentNode: CCNode!//Keeps controls on screen
    weak var backgroundNode: CCNode!//backgrounds stay here
    
    var sceneArray: [CCNode] = []//Holds the scenes
    var enemyArray: [BasicEnemy] = []//array of BasicEnemy's in addEnemy(xCor, yCor)
    var backgroundArray: [CCNode] = []//array of backgrounds, to keep scrolling
    
    var jumped = true//move to hero class later
    var gameOver = false//keeps track of when game ends
    var limitShots = 0//limits enemies to shooting once per 28 frames
    var heroShots = 30//limits hero to shooting once per 30 frames (one sec)
    var numBasicEnemies = 0//keeps track of num of enemies.  Add one as starts at 0
    var heroHealth = 3//hero health, goes down when hit with shot
    var sceneNum = 0//how far to add a scene
    var heroXPos = 1512//When to delete scenes
    var scenesGone = 0//how many scenes are deleted
    var enemiesGone = 0//keeps track of deleted enemies
    var enemyLocation = 906//x location of next enemy
    var backgroundLocation = -300//x location of background
    var backgroundGone = 0//keeps track of backgrounds in array
    var enemiesKilled = 0//score
    
    func didLoadFromCCB() {
        addBackground()
        addBackground()
        addBackground()
        addScene("Scenes/BeginningScene")
        addScene("Scenes/Scene1")
        addScene("Scenes/Scene2")
        numBasicEnemies--
        userInteractionEnabled = true
        gamePhysicsNode.collisionDelegate = self
    }
    
    func addScene(sceneName: String) {
        let level = CCBReader.load(sceneName)
        sceneArray.append(level)
        gamePhysicsNode.addChild(level)
        level.position.x = CGFloat(sceneNum)
        addEnemy(CGFloat(150 + sceneNum), yCor: 150)
        addEnemy(CGFloat(475 + sceneNum), yCor: 150)
        sceneNum = sceneNum + 756
    }
    
    func addEnemy(xCor: CGFloat, yCor: CGFloat) {
        let temporaryBasicEnemy = CCBReader.load("BasicEnemy") as! BasicEnemy
        enemyArray.append(temporaryBasicEnemy)
        temporaryBasicEnemy.position = CGPoint(x: xCor, y: yCor)
        enemyNode.addChild(temporaryBasicEnemy)
        numBasicEnemies++
    }
    
    func addBackground() {
        let tempBackground = CCBReader.load("Background")
        backgroundArray.append(tempBackground)
        backgroundNode.addChild(tempBackground)
        tempBackground.position = CGPoint(x: backgroundLocation, y: 0)
        backgroundLocation = backgroundLocation + 850
    }
    
    override func fixedUpdate(delta: CCTime) {
        if gameOver == false {
            if hero.position.y <= 0 {
                endGame()
            }
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
        if hero.position.x >= CGFloat(heroXPos) {
            enemyNode.removeChild(enemyArray[enemiesGone])
            enemiesGone++
            enemyNode.removeChild(enemyArray[enemiesGone])
            enemiesGone++
            sceneArray[scenesGone].removeFromParent()
            heroXPos = heroXPos + 756
            scenesGone++
            var value = Int(arc4random_uniform(2))
            println(value)
            if value == 0 {
                addScene("Scenes/Scene1")
            }
            if value == 1 {
                addScene("Scenes/Scene2")
            }
        }
        if hero.position.x >= CGFloat(backgroundLocation) {
            backgroundArray[backgroundGone].removeFromParent()
            backgroundGone++
            addBackground()
            addBackground()
        }
        position = CGPoint.zeroPoint
        let actionFollow = CCActionFollow(target: hero)
        contentNode.runAction(actionFollow)
        heroShots++
        limitShots++
    }
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if gameOver == false {
        if touch.locationInWorld().x >= 17 && touch.locationInWorld().y >= 7 && touch.locationInWorld().x <= 81 && touch.locationInWorld().y <= 47 {
            hero.movementState = HeroMovementState.MovingLeft
            hero.walkAnimate()
            hero.scaleX = -1
        }
        
        if touch.locationInWorld().x >= 112 && touch.locationInWorld().y >= 7 && touch.locationInWorld().x <= 176 && touch.locationInWorld().y <= 47 {
            hero.movementState = HeroMovementState.MovingRight
            hero.walkAnimate()
            hero.scaleX = 1
        }
    }
    }
    
    override func touchEnded(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if gameOver == false {
        if hero.movementState == HeroMovementState.MovingRight {
            hero.idleAnimate()
            hero.movementState = HeroMovementState.IdleRight
        }
        else if hero.movementState == HeroMovementState.MovingLeft {
            hero.idleAnimate()
            hero.movementState = HeroMovementState.IdleLeft
        }
    }
    }

    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, falling: Hero!, ground: CCNode!) {
        if jumped == true {
            if hero.jump.visible == true {
                hero.idleAnimate()
            }
            jumped = false
        }
    }
    
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, falling: Hero!, wall: CCNode!) {
        if jumped == true {
            if hero.jump.visible == true {
                hero.idleAnimate()
            }
            jumped = false
        }
    }
    
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, falling: Hero!, basicEnemyShot: CCParticleSystem!) {
        heroHealth--
        if basicEnemyShot.position.x < falling.position.x {
            self.hero.physicsBody.applyImpulse(CGPoint(x: -18, y: 0))
        }
        else if basicEnemyShot.position.x > falling.position.x {
            self.hero.physicsBody.applyImpulse(CGPoint(x: 18, y: 0))
        }
        if heroHealth == 0 {
            endGame()
        }
    }
    
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, falling: Hero!, basicEnemyCrash: BasicEnemy!) {
//        heroHealth--
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
    
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, basicEnemyShot: CCParticleSystem!, wildcard: CCNode!) {
        self.gamePhysicsNode.removeChild(basicEnemyShot)
    }
    
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, basicEnemyCrash: BasicEnemy!, basicEnemyShot: CCParticleSystem!) {
        
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
        let explosion = CCBReader.load("HeroDeath") as! CCParticleSystem
        explosion.autoRemoveOnFinish = true
        explosion.position = basicEnemyCrash.position
        basicEnemyCrash.parent.addChild(explosion)
        enemyNode.removeChild(basicEnemyCrash)
        enemiesKilled++
    }
    
    func jump() {
        if self.jumped == false && gameOver == false {
            self.hero.physicsBody.applyImpulse(CGPoint(x: 0, y: 25))
            self.jumped = true
            self.hero.jumpAnimate()
        }
    }
    
    func shoot() {
        if heroShots >= 30 && gameOver == false {
            heroShots = 0
            hero.hasShot()
            let explosion = CCBReader.load("Shot") as! CCParticleSystem
            explosion.autoRemoveOnFinish = true
            explosion.position.y = (hero.position.y + 5)
            explosion.position.x = (hero.position.x + CGFloat(hero.shotMoveScale))
            gamePhysicsNode.addChild(explosion)
            explosion.physicsBody.applyImpulse(CGPoint(x: hero.shotImpulseScale, y: 0))
        }
    }
    
    func basicEnemyShot(enemyPos: BasicEnemy) {
        let explosionEnemy = CCBReader.load("BasicEnemyShot") as! CCParticleSystem
        explosionEnemy.autoRemoveOnFinish = true
        explosionEnemy.position.y = (enemyPos.position.y + 5)
        explosionEnemy.position.x = (enemyPos.position.x + CGFloat(enemyPos.shotMoveScale))
        gamePhysicsNode.addChild(explosionEnemy)
        explosionEnemy.physicsBody.applyImpulse(CGPoint(x: enemyPos.shotImpulseScale, y: 0))
    }
    
    func endGame() {
        gameOver = true
        let explosion = CCBReader.load("HeroDeath") as! CCParticleSystem
        explosion.autoRemoveOnFinish = true
        explosion.position = hero.position
        hero.parent.addChild(explosion)
        hero.removeFromParent()
        var gameEndPopover = CCBReader.load("GameOver", owner: self) as! GameOver
        gameEndPopover.setMessage(enemiesKilled)
        addChild(gameEndPopover)
    }
    
    func restart() {
        gamePhysicsNode.removeAllChildrenWithCleanup(true)
        sceneArray.removeAll(keepCapacity: false)
        enemyArray.removeAll(keepCapacity: false)
        let gameplayScene = CCBReader.loadAsScene("MainScene")
        CCDirector.sharedDirector().presentScene(gameplayScene)
    }
}