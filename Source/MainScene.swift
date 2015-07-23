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
    weak var lifeLabel: CCLabelTTF!//life left
    weak var gameScoreLabel: CCLabelTTF!//Score in game
    weak var pauseScreen: CCNode!//faded node over everything
    
    var sceneArray: [CCNode] = []//Holds the scenes
    var enemyArray: [BasicEnemy] = []//array of BasicEnemy's in addEnemy(xCor, yCor)
    var backgroundArray: [CCNode] = []//array of backgrounds, to keep scrolling
    var enemyCanShoot: [Bool] = []//whether or not enemy can shoot
    var missleArray: [CCNode] = []//array of missles
    var limitShots: [Int] = []//limit enemy shots to once per 28 frames
    
    var jumped = true//move to hero class later
    var gameOver = false//keeps track of when game ends
    var heroShots = 30//limits hero to shooting once per 30 frames (one sec)
    var numBasicEnemies = 0//keeps track of num of enemies.
    var heroHealth = 0//hero health, goes down when hit with shot
    var sceneNum = 0//how far to add a scene
    var heroXPos = 1512//When to delete scenes
    var scenesGone = 0//how many scenes are deleted
    var enemiesGone = 0//keeps track of deleted enemies
    var enemyLocation = 906//x location of next enemy
    var backgroundLocation = -300//x location of background
    var backgroundGone = 0//keeps track of backgrounds in array
    var enemiesKilled = 0//score of enemies killed ( and scenes completed?)
    var isBoss = false//whether or not updates boss
    var bossSeconds = 0//bossShooting to a minimum, and after aims
    var isAiming = false//controls when it can shoot
    var numMissles = 0//how many missles there are
    var isShooting = false//only updates missles while boss is shooting
    var bossHealth = 10//health of the boss
    var beginTouchX = CGFloat(0)//part of touch detection for movement
    var beginTouchY = CGFloat(0)//*same as above
    var fireRateDefault = 0//fire rate in NSUserdefaults
    var speed = 0//default speed
    
    let temporaryBoss = CCBReader.load("HeavyTerror") as! HeavyTerror
    let mainMenu = CCBReader.loadAsScene("MainMenu")
    let defaults = NSUserDefaults.standardUserDefaults()
    
    func didLoadFromCCB() {
        addBackground()
        addBackground()
        addBackground()
        addScene("Scenes/BeginningScene")
        addScene("Scenes/Scene2")
        addScene("Scenes/Scene1")
        numBasicEnemies--
        userInteractionEnabled = true
        multipleTouchEnabled = true
        gamePhysicsNode.collisionDelegate = self
        
//        defaults.setBool(false, forKey: "startup")
        heroHealth = defaults.integerForKey("life")
        fireRateDefault = defaults.integerForKey("rate")
        speed = defaults.integerForKey("speed")
        
        lifeLabel.string = "\(heroHealth)"
    }
    
    func addScene(sceneName: String) {
        let level = CCBReader.load(sceneName)
        sceneArray.append(level)
        gamePhysicsNode.addChild(level)
        level.position.x = CGFloat(sceneNum)
        if sceneName == "Scenes/BossScene" {
            addHeavyTerror(sceneNum)
            addEnemy(CGFloat(100 + sceneNum), yCor: 150)
            addEnemy(CGFloat(200 + sceneNum), yCor: 150)
            addEnemy(CGFloat(300 + sceneNum), yCor: 150)
        }
        else {
            addEnemy(CGFloat(250 + sceneNum), yCor: 150)
            addEnemy(CGFloat(475 + sceneNum), yCor: 150)
        }
        sceneNum = sceneNum + 756
    }
    
    func addEnemy(xCor: CGFloat, yCor: CGFloat) {
        let temporaryBasicEnemy = CCBReader.load("BasicEnemy") as! BasicEnemy
        enemyArray.append(temporaryBasicEnemy)
        temporaryBasicEnemy.position = CGPoint(x: xCor, y: yCor)
        enemyNode.addChild(temporaryBasicEnemy)
        var rightOrLeft = Int(arc4random_uniform(2))
        if rightOrLeft == 0 {
            temporaryBasicEnemy.scaleX = 1
        }
        else if rightOrLeft == 1 {
            temporaryBasicEnemy.scaleX = -1
        }
        numBasicEnemies++
        enemyCanShoot.append(true)
        limitShots.append(0)
    }
    
    func addHeavyTerror(sceneNum: Int) {
        temporaryBoss.position = CGPoint(x: sceneNum + 675, y: 300)
        enemyNode.addChild(temporaryBoss)
        isBoss = true
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
            if isBoss == true && hero.position.x >= (temporaryBoss.position.x - 600) {
                updateBoss()
                bossSeconds++
            }
            for index in enemiesGone...numBasicEnemies {
                limitShots[index] = limitShots[index] + 1
                if enemyArray[index].detectHero(hero.position.y, xCor: hero.position.x, scale: -1) && enemyArray[index].scaleX == -1 && limitShots[index] >= 28 && enemyCanShoot[index] == true {
                    basicEnemyShot(enemyArray[index])
                    limitShots[index] = 0
                }
                else if enemyArray[index].detectHero(hero.position.y, xCor: hero.position.x, scale: 1) && enemyArray[index].scaleX == 1 && limitShots[index] >= 28 && enemyCanShoot[index] == true {
                    basicEnemyShot(enemyArray[index])
                    limitShots[index] = 0
                }//This else if not needed??
                else {
                    enemyArray[index].move()
                }
            }
            if hero.movementState == HeroMovementState.MovingRight {
                hero.physicsBody.velocity.x = CGFloat(speed)
            }
            else if hero.movementState == HeroMovementState.MovingLeft {
                hero.physicsBody.velocity.x = CGFloat(-speed)
            }
            if hero.position.x >= CGFloat(heroXPos) {
                enemyArray[enemiesGone].removeFromParent()
                enemyGone(enemyArray[enemiesGone])
                enemiesGone++
                enemyArray[enemiesGone].removeFromParent()
                enemyGone(enemyArray[enemiesGone])
                enemiesGone++
                sceneArray[scenesGone].removeFromParent()
                heroXPos = heroXPos + 756
                scenesGone++
                if scenesGone % 4 == 0 {
                    addScene("Scenes/BossScene")
//                    println("Boss")
                }
                else {
                    var value = Int(arc4random_uniform(3))
//                    println(value)
                    if value == 0 {
                        addScene("Scenes/Scene1")
                    }
                    else if value == 1 {
                        addScene("Scenes/Scene2")
                    }
                    else if value == 2 {
                        addScene("Scenes/Scene3")
                    }
                }
            }
            if hero.position.x >= CGFloat(backgroundLocation) {
                backgroundArray[backgroundGone].removeFromParent()
                backgroundGone++
                addBackground()
            }
            position = CGPoint.zeroPoint
            let actionFollow = CCActionFollow(target: hero)
            contentNode.runAction(actionFollow)
            heroShots++
        }
    }
    
    func updateBoss() {
        if isAiming == false {
            temporaryBoss.aim()
            isAiming = true
            bossSeconds = 0
        }
        else if bossSeconds >= 45 {
            bossShot(temporaryBoss)
            bossSeconds = 0
        }
        missleUpdate()
    }
    
    func missleUpdate() {
        if isShooting == true {
            for index in 0...(numMissles - 1) {
                if missleArray[index].position.y >= 400 {
                    missleArray[index].physicsBody.velocity = CGPoint(x: 0, y: -70)
                    missleArray[index].position.y = 350
                    missleArray[index].rotation = -180
                    missleArray[index].position.x = hero.position.x
                }
            }
        }
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if gameOver == false {
            beginTouchX = touch.locationInWorld().x
            beginTouchY = touch.locationInWorld().y
        }
    }
    
    override func touchMoved(touch : CCTouch, withEvent: CCTouchEvent) {//check make2048 for their swipe gestures?
        if gameOver == false {
            var screenSeg = CCDirector.sharedDirector().viewSize().width / 2
            if touch.locationInWorld().x > screenSeg && self.jumped == false && beginTouchY < touch.locationInWorld().y {
                hero.physicsBody.velocity.y = 80//100 just a little too much
                hero.physicsBody.velocity.x = 0
                hero.jumpAnimate()
                jumped = true
            }
            //            else if touch.locationInWorld().x > screenSeg {
            //                heroShot()
            //            }
            
            if touch.locationInWorld().x > beginTouchX && touch.locationInWorld().x < screenSeg && (hero.movementState == HeroMovementState.IdleRight || hero.movementState == HeroMovementState.IdleLeft || hero.movementState == HeroMovementState.MovingLeft) {
                hero.movementState = HeroMovementState.MovingRight
                hero.walkAnimate()
                hero.scaleX = 1
            }
            else if touch.locationInWorld().x < beginTouchX && touch.locationInWorld().x < screenSeg && (hero.movementState == HeroMovementState.IdleRight || hero.movementState == HeroMovementState.IdleLeft || hero.movementState == HeroMovementState.MovingRight) {
                hero.movementState = HeroMovementState.MovingLeft
                hero.walkAnimate()
                hero.scaleX = -1
            }
        }
    }
    
    override func touchEnded(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if gameOver == false {
            hero.physicsBody.velocity.x = CGFloat(0)
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
                if hero.movementState == HeroMovementState.MovingRight || hero.movementState == HeroMovementState.MovingLeft {
                    hero.walkAnimate()
                }
                else {
                    hero.idleAnimate()
                }
                hero.physicsBody.velocity.x = CGFloat(0)
            }
            jumped = false
        }
        }
    
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, falling: Hero!, wall: CCNode!) {
        if jumped == true {
            if hero.jump.visible == true {
                if hero.movementState == HeroMovementState.IdleRight || hero.movementState == HeroMovementState.IdleLeft {
                    hero.idleAnimate()
                }
                else {
                    hero.walkAnimate()
                }
                hero.physicsBody.velocity.x = CGFloat(0)
            }
            jumped = false
        }
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, falling: Hero!, basicEnemyShot: CCParticleSystem!) -> Bool {
        self.gamePhysicsNode.removeChild(basicEnemyShot)
        heroHealth--
        lifeLabel.string = "\(heroHealth)"
        if heroHealth == 0 {
            endGame()
        }
        return false
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, falling: Hero!, basicEnemyCrash: BasicEnemy!) -> Bool {
//        heroHealth--
        return false
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
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, basicEnemyCrash: BasicEnemy!, basicEnemyShot: CCParticleSystem!) -> Bool {
        return false
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
//        enemyNode.removeChild(basicEnemyCrash)
        basicEnemyCrash.removeFromParentAndCleanup(true)
        enemiesKilled++
        gameScoreLabel.string = "\(enemiesKilled)"
        enemyGone(basicEnemyCrash)
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, basicEnemyCrash: BasicEnemy!, bossMissleCrash: CCNode!) -> Bool {
        return false
    }
    
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, bossMissleCrash: CCNode!, wildcard: CCNode!) {
        self.gamePhysicsNode.removeChild(bossMissleCrash)
        let explosion = CCBReader.load("MissleExplosion", owner: self) as CCNode
        explosion.position.y = (bossMissleCrash.position.y)
        explosion.position.x = (bossMissleCrash.position.x)
        explosion.userObject.setCompletedAnimationCallbackBlock { (sender: AnyObject!) -> Void in
        explosion.removeFromParentAndCleanup(true)
        }
        gamePhysicsNode.addChild(explosion)
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, falling: Hero!, bossMissleCrash: CCNode!) -> Bool {
        heroHealth--
        lifeLabel.string = "\(heroHealth)"
        if heroHealth == 0 {
            endGame()
        }
        bossMissleCrash.removeFromParentAndCleanup(true)
        let explosion = CCBReader.load("MissleExplosion", owner: self) as CCNode
        explosion.position.y = (bossMissleCrash.position.y)
        explosion.position.x = (bossMissleCrash.position.x)
        explosion.userObject.setCompletedAnimationCallbackBlock { (sender: AnyObject!) -> Void in
        explosion.removeFromParentAndCleanup(true)
        }
        gamePhysicsNode.addChild(explosion)
        return false
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, shot: CCNode!, heavyTerrorCrash: HeavyTerror!) -> Bool {
        bossHealth--
        if bossHealth == 0 {
            let explosion = CCBReader.load("BossDeath") as! CCParticleSystem
            explosion.autoRemoveOnFinish = true
            explosion.position = heavyTerrorCrash.position
            heavyTerrorCrash.parent.addChild(explosion)
            enemyNode.removeChild(heavyTerrorCrash)
            isBoss = false
            missleArray.removeAll(keepCapacity: false)
            enemiesKilled = enemiesKilled + 5
            gameScoreLabel.string = "\(enemiesKilled)"
        }
        return false
    }
    
    func enemyGone(noShooting: BasicEnemy!) {
            var i = 0
            i = find(enemyArray, noShooting)!
            enemyCanShoot[i] = false
    }
    
    func shoot() {
//        var fireRateDefault = defaults.integerForKey("rate")
        if heroShots >= fireRateDefault && gameOver == false {
//            println("1")
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
    
    func heroShot() {
        if heroShots >= 30 && gameOver == false {
//            println("2")
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
    
    func bossShot(bossPos: HeavyTerror) {
        numMissles++
        isShooting = true
        let explosionEnemy = CCBReader.load("BossMissle") as CCNode
        explosionEnemy.position.y = (bossPos.position.y + 50)
        explosionEnemy.position.x = (bossPos.position.x - 50)
        explosionEnemy.rotation = -45
        missleArray.append(explosionEnemy)
        gamePhysicsNode.addChild(explosionEnemy)
        explosionEnemy.physicsBody.applyImpulse(CGPoint(x: -20, y: 30))
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
        
        var totalScore = defaults.integerForKey("highscore")
        totalScore = totalScore + enemiesKilled
        defaults.setInteger(totalScore, forKey: "highscore")
        println(totalScore)
    }
    
    func restart() {
        gamePhysicsNode.removeAllChildrenWithCleanup(true)
        sceneArray.removeAll(keepCapacity: false)
        enemyArray.removeAll(keepCapacity: false)
        backgroundArray.removeAll(keepCapacity: false)
        enemyCanShoot.removeAll(keepCapacity: false)
        let gameplayScene = CCBReader.loadAsScene("MainScene")
        CCDirector.sharedDirector().presentScene(gameplayScene)
    }
    
    func pause() {
        if gameOver == false {
        pauseScreen.visible = true
        self.paused = true
        }
    }
    
    func playScreen() {
        pauseScreen.visible = false
        self.paused = false
    }
    
    func mainMenuScreen() {
        CCDirector.sharedDirector().presentScene(mainMenu)
    }
}