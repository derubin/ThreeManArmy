//
//  MainScene.swift
//  ThreeManArmy
//
//  Created by Daniel Rubin on 7/7/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//
//  Note, gameOver creates new scenes, have to delete them as well - memory issues
//  Separation for background is 850, starts at 750, for scenes: 756
//  Bug Note:  Beginning of game, shots stay in place until hero moves left or right. Unknown reason
//  No fire rate
//  Fix broken physics for hero in the wall
//  Make AI better
//  if missle crashes out of the order it was shot in, crashes.

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
    weak var hurtNode: CCNode!//Red Node that flashes when hurt
    weak var explainScreen: CCNodeColor!
    
    weak var testLabel: CCLabelTTF!
    
    var sceneArray: [CCNode] = []//Holds the scenes
    var enemyArray: [BasicEnemy] = []//array of BasicEnemy's in addEnemy(xCor, yCor)
    var backgroundArray: [CCNode] = []//array of backgrounds, to keep scrolling
    var enemyCanShoot: [Bool] = []//whether or not enemy can shoot
    var missleArray: [CCNode] = []//array of missles
    var limitShots: [Int] = []//limit enemy shots to once per 28 frames
    var enemyHealth: [Int] = []//have enemies take multiple shots
    
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
    var misslesGone = 0//how many gone, keeps CPU under control
    var isShooting = false//only updates missles while boss is shooting
    var bossHealth = 10//health of the boss
    var previousBossHealth = 10//previous health of boss
    var beginTouchX = CGFloat(0)//part of touch detection for movement
    var beginTouchY = CGFloat(0)//*same as above
    var fireRateDefault = 0//fire rate in NSUserdefaults
    var speed = 0//default speed
    var isTutorial = false//true when a tutorial is up, goes away with next swipe
    var isHurt = 20//red pops up when hit, disappears in 10 frames
    var screenSeg = CCDirector.sharedDirector().viewSize().width / 2//Used to limit movement
    var bossDetect = 250
    var bossHit = false
    
    var collide = false
    var missleCollide = false
    var enemyShotCollide = false
    var heroShotCollide = false
    
    var enemies = 0//for highscore page
    var bosses = 0//*same as above
    
    var enemyHealthNum = 1
    var bossRate = 50
    
    var justShot = false
    
    let temporaryBoss = CCBReader.load("HeavyTerror") as! HeavyTerror
    let mainMenu = CCBReader.loadAsScene("MainMenu")
    let defaults = NSUserDefaults.standardUserDefaults()
    let tutorial = CCBReader.load("Tutorial") as! Tutorial
    let wall = CCBReader.load("Wall") as! Wall
    
    func didLoadFromCCB() {
//        resetDefaults()
        if defaults.integerForKey("life") == 0 && defaults.integerForKey("rate") == 0 && defaults.integerForKey("speed") == 0{
            defaults.setInteger(150, forKey: "speed")
            defaults.setInteger(15, forKey: "rate")
            defaults.setInteger(1, forKey: "life")
            defaults.setInteger(5, forKey: "speedLabel")
            defaults.setInteger(5, forKey: "rateLabel")
            defaults.setInteger(5, forKey: "lifeLabel")
        }
        
//        gamePhysicsNode.debugDraw = true
        
        tutorialScreen()
        addBackground()
        addBackground()
        addBackground()
        addScene("Scenes/BeginningScene")
        addScene("Scenes/Scene1")
        addScene("Scenes/Scene2")
//        addScene("Scenes/BossScene")
        numBasicEnemies--
        userInteractionEnabled = true
        multipleTouchEnabled = true
        gamePhysicsNode.collisionDelegate = self
        
        heroHealth = defaults.integerForKey("life")
        fireRateDefault = defaults.integerForKey("rate")
        speed = defaults.integerForKey("speed")
        
        lifeLabel.string = "\(heroHealth)"
        
        setupGestures()
//        setupTaps()
        gamePhysicsNode.addChild(wall)
        wall.position.x = -500
    }
    
    func addScene(sceneName: String) {
        let level = CCBReader.load(sceneName)
        sceneArray.append(level)
        gamePhysicsNode.addChild(level)
        level.position.x = CGFloat(sceneNum)
        
        wall.position.x = CGFloat(sceneNum - 1512)
        
        if sceneName == "Scenes/BossScene" {
            addHeavyTerror(sceneNum)
            addEnemy(CGFloat(250 + sceneNum), yCor: 150)
            addEnemy(CGFloat(400 + sceneNum), yCor: 150)
        }
        else if sceneName == "Scenes/BeginningScene" {
            addEnemy(CGFloat(475 + sceneNum), yCor: 110)
            addEnemy(-500, yCor: -500)
        }
        else if sceneName == "Scenes/Scene1" {
            addEnemy(CGFloat(250 + sceneNum), yCor: 110)
            addEnemy(CGFloat(500 + sceneNum), yCor: 110)
        }
        else {
            addEnemy(CGFloat(250 + sceneNum), yCor: 110)
            addEnemy(CGFloat(475 + sceneNum), yCor: 110)
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
            temporaryBasicEnemy.movementState = BasicEnemyState.MovingRight
        }
        else if rightOrLeft == 1 {
            temporaryBasicEnemy.scaleX = -1
            temporaryBasicEnemy.movementState = BasicEnemyState.MovingLeft
        }
        numBasicEnemies++
        enemyCanShoot.append(true)
        enemyHealth.append(1)
        limitShots.append(0)
    }
    
    func addHeavyTerror(sceneNum: Int) {
        enemyNode.addChild(temporaryBoss)
        temporaryBoss.position = CGPoint(x: sceneNum + 650, y: 250)
        isBoss = true
        temporaryBoss.idleWait()
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
            if isBoss == true && (hero.position.x >= (temporaryBoss.position.x - CGFloat(bossDetect)) || bossHit == true) {
                bossDetect = 1550
                updateBoss()
                bossSeconds++
                if temporaryBoss.isClose == false {
                    numMissles = 0
                    misslesGone = 0
                    bossDetect = 250
                    temporaryBoss.isClose = true
                }
            }
            if isHurt >= 10 {
                hurtNode.visible = false
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
                }
                else {
                    enemyArray[index].move()
                }
            }
            if hero.isShooting == true && heroShots > 25 && (hero.movementState == HeroMovementState.MovingRight || hero.movementState == HeroMovementState.MovingLeft) {//Hack, replace if everything breaks
                hero.isShooting = false
                hero.walkAnimate()
            }
            else if hero.isShooting == true && heroShots > 25 && (hero.movementState == HeroMovementState.IdleRight || hero.movementState == HeroMovementState.IdleLeft) {
                hero.isShooting = false
                hero.idleAnimate()
            }
            if hero.movementState == HeroMovementState.MovingRight {
                hero.physicsBody.velocity.x = CGFloat(speed)
            }
            else if hero.movementState == HeroMovementState.MovingLeft {
                hero.physicsBody.velocity.x = CGFloat(-speed)
            }
            if hero.position.x >= CGFloat(heroXPos) {
                enemiesKilled = enemiesKilled + 5
                gameScoreLabel.string = "\(enemiesKilled)"
                enemyArray[enemiesGone].removeFromParentAndCleanup(true)
                enemyGone(enemyArray[enemiesGone])
                enemiesGone++
                enemyArray[enemiesGone].removeFromParentAndCleanup(true)
                enemyGone(enemyArray[enemiesGone])
                enemiesGone++
                sceneArray[scenesGone].removeFromParentAndCleanup(true)
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
            isHurt++
        }
    }
    
    func updateBoss() {
        if isAiming == false {
            temporaryBoss.aim()
            isAiming = true
            bossSeconds = 0
            isShooting = false
        }
        else if bossSeconds >= 45 {
            bossShot(temporaryBoss)
            bossSeconds = 0
            isShooting = true
            missleUpdate()
        }
//        missleUpdate()
    }
    
    func missleUpdate() {
        if isShooting == true {
//            println(misslesGone)
//            println(numMissles)
            if misslesGone == numMissles {
                numMissles++
            }
//            println(misslesGone)
//            println(numMissles)
//            println()
            for index in misslesGone...(numMissles - 1) {
                if missleArray[index] != [] {
                    if missleArray[index].position.y >= 400 {
                        missleArray[index].physicsBody.velocity = CGPoint(x: 0, y: -70)
                        missleArray[index].position.y = 350
                        missleArray[index].rotation = -180
                        missleArray[index].position.x = hero.position.x
                    }
                }
            }
        }
    }
    
    func otherMoveMethod() {
//    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
//        if gameOver == false {
//            beginTouchX = touch.locationInWorld().x
//            beginTouchY = touch.locationInWorld().y
//        }
//    }
//    
//    override func touchMoved(touch : CCTouch, withEvent: CCTouchEvent) {
//        if gameOver == false {
//            var screenSeg = CCDirector.sharedDirector().viewSize().width / 2
//            if touch.locationInWorld().x > screenSeg && self.jumped == false && beginTouchY < touch.locationInWorld().y {
//                hero.physicsBody.velocity.y = 80//100 just a little too much
////                hero.physicsBody.velocity.x = 0
//                hero.jumpAnimate()
//                jumped = true
//            }
////            else if touch.locationInWorld().x > screenSeg {
////                heroShot()
////            }
//            
//            if touch.locationInWorld().x > beginTouchX && touch.locationInWorld().x < screenSeg && (hero.movementState == HeroMovementState.IdleRight || hero.movementState == HeroMovementState.IdleLeft || hero.movementState == HeroMovementState.MovingLeft) {
//                hero.movementState = HeroMovementState.MovingRight
//                hero.walkAnimate()
//                hero.scaleX = 1
//            }
//            else if touch.locationInWorld().x < beginTouchX && touch.locationInWorld().x < screenSeg && (hero.movementState == HeroMovementState.IdleRight || hero.movementState == HeroMovementState.IdleLeft || hero.movementState == HeroMovementState.MovingRight) {
//                hero.movementState = HeroMovementState.MovingLeft
//                hero.walkAnimate()
//                hero.scaleX = -1
//            }
//        }
//    }
//    
//    override func touchEnded(touch: CCTouch!, withEvent event: CCTouchEvent!) {
//        if gameOver == false {
////            hero.physicsBody.velocity.x = CGFloat(0)
//            if hero.movementState == HeroMovementState.MovingRight {
//                hero.idleAnimate()
//                hero.movementState = HeroMovementState.IdleRight
//                hero.physicsBody.velocity.x = CGFloat(0)
//            }
//            else if hero.movementState == HeroMovementState.MovingLeft {
//                hero.idleAnimate()
//                hero.movementState = HeroMovementState.IdleLeft
//                hero.physicsBody.velocity.x = CGFloat(0)
//            }
//        }
//        }
}

    func setupGestures() {
//        var swipeLeft = UISwipeGestureRecognizer(target: self, action: "swipeLeft")
//        swipeLeft.direction = .Left
//        CCDirector.sharedDirector().view.addGestureRecognizer(swipeLeft)
//        
//        var swipeRight = UISwipeGestureRecognizer(target: self, action: "swipeRight")
//        swipeRight.direction = .Right
//        CCDirector.sharedDirector().view.addGestureRecognizer(swipeRight)
        
        var swipeUp = UISwipeGestureRecognizer(target: self, action: "swipeUp")
        swipeUp.direction = .Up
        CCDirector.sharedDirector().view.addGestureRecognizer(swipeUp)
        
        var swipeDown = UISwipeGestureRecognizer(target: self, action: "swipeDown")
        swipeDown.direction = .Down
        CCDirector.sharedDirector().view.addGestureRecognizer(swipeDown)
    }
    
    func setupTaps() {
        var tapShoot = UITapGestureRecognizer(target: self, action: "tapShoot")
        CCDirector.sharedDirector().view.addGestureRecognizer(tapShoot)
    }
    
    func moveMethodsTakeTwo() {
//    func swipeLeft() {
//        println("Left")
//        if gameOver == false {
//            if isTutorial == true {
//                isTutorial = false
//                tutorial.removeFromParentAndCleanup(true)
//            }
//           hero.movementState = HeroMovementState.MovingLeft
//           hero.walkAnimate()
//           hero.scaleX = -1
//        }
//    }
//
//    func swipeRight() {
//        println("Right")
//        if gameOver == false {
//            if isTutorial == true {
//                isTutorial = false
//                tutorial.removeFromParentAndCleanup(true)
//            }
//           hero.movementState = HeroMovementState.MovingRight
//           hero.walkAnimate()
//           hero.scaleX = 1
//        }
//    }
    }
    
    func swipeUp() {
//        println("Up")
        if gameOver == false && jumped == false && beginTouchX >= screenSeg {
            if isTutorial == true {
                isTutorial = false
                tutorial.removeFromParentAndCleanup(true)
            }
            hero.physicsBody.velocity.y = 90//100 just a little too much
            hero.jumpAnimate()
            jumped = true
        }
    }

    func swipeDown() {
//        println("Down")
        if gameOver == false && beginTouchX >= screenSeg {
            if isTutorial == true {
                isTutorial = false
                tutorial.removeFromParentAndCleanup(true)
            }
//            if jumped == true {
                hero.physicsBody.velocity.y = -200
//            }
//            hero.idleAnimate()
//            if hero.movementState == HeroMovementState.MovingRight {
//                hero.movementState = HeroMovementState.IdleRight
//            }
//            else if hero.movementState == HeroMovementState.MovingLeft {
//                hero.movementState = HeroMovementState.IdleLeft
//            }
//            hero.physicsBody.velocity.x = 0
        }
    }
    
    override func touchEnded(touch: CCTouch!, withEvent event: CCTouchEvent!) {
//        println("End")
        if gameOver == false {
//            if justShot == true {
//                justShot = false
//            }
            if touch.locationInWorld().x > screenSeg {
                tapShoot()
                justShot = true
            }
            else if hero.movementState == HeroMovementState.MovingRight {
                hero.physicsBody.velocity.x = 0
                hero.idleAnimate()
                hero.movementState = HeroMovementState.IdleRight
            }
            else if hero.movementState == HeroMovementState.MovingLeft {
                hero.physicsBody.velocity.x = 0
                hero.idleAnimate()
                hero.movementState = HeroMovementState.IdleLeft
            }
        }
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
//        println("Begin")
        if gameOver == false {
            beginTouchX = touch.locationInWorld().x
            beginTouchY = touch.locationInWorld().y
//            if touch.locationInWorld().x > screenSeg {
//                tapShoot()
//                justShot = true
//            }
        }
    }
    
    override func touchMoved(touch: CCTouch!, withEvent event: CCTouchEvent!) {
//        println("Moved")
        if gameOver == false {
             if touch.locationInWorld().y < (beginTouchY + 5) && beginTouchX <= screenSeg {
                if isTutorial == true {
                    isTutorial = false
                    tutorial.removeFromParentAndCleanup(true)
                }
                if touch.locationInWorld().x > beginTouchX && hero.movementState != HeroMovementState.MovingRight {
                    hero.movementState = HeroMovementState.MovingRight
                    hero.walkAnimate()
                    hero.scaleX = 1
                }
                else if touch.locationInWorld().x < beginTouchX && hero.movementState != HeroMovementState.MovingLeft {
                    hero.movementState = HeroMovementState.MovingLeft
                    hero.walkAnimate()
                    hero.scaleX = -1
                }
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
    
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, falling: Hero!, basicEnemyShot: CCParticleSystem!) {
        enemyShotCollide = true
        if basicEnemyShot.position.x >= falling.position.x {
            heroHurt(true)
        }
        else {
            heroHurt(false)
        }
        self.gamePhysicsNode.removeChild(basicEnemyShot)
        lifeLabel.string = "\(heroHealth)"
        if heroHealth <= 0 {
            endGame()
        }
    }
    
    func ccPhysicsCollisionSeparate(pair: CCPhysicsCollisionPair!, falling: Hero!, basicEnemyCrash: BasicEnemy!) {
        collide = false
    }
    
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, falling: Hero!, basicEnemyCrash: BasicEnemy!) {
        if collide == false {
            collide = true
            if basicEnemyCrash.position.x >= falling.position.x {
                heroHurt(true)
            }
            else {
                heroHurt(false)
            }
            lifeLabel.string = "\(heroHealth)"
            if heroHealth <= 0 {
                endGame()
            }
            if basicEnemyCrash.scaleX == -1 {
                basicEnemyCrash.scaleX = 1
                basicEnemyCrash.movementState = BasicEnemyState.MovingRight
            }
            else if basicEnemyCrash.scaleX == 1 {
                basicEnemyCrash.scaleX = -1
                basicEnemyCrash.movementState = BasicEnemyState.MovingLeft
            }
        }
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
        if heroShotCollide == false {
            self.gamePhysicsNode.removeChild(shot)
        }
        heroShotCollide = false
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, shot: CCParticleSystem!, falling: Hero!) -> ObjCBool {
        return false
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, shot type1: CCParticleSystem!, shot type2: CCParticleSystem!) -> ObjCBool {
        return false
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, basicEnemyShot shot1: CCParticleSystem!, basicEnemyShot shot2: CCParticleSystem!) -> ObjCBool {
        return false
    }
    
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, basicEnemyShot: CCParticleSystem!, wildcard: CCNode!) {
        if enemyShotCollide == false {
            self.gamePhysicsNode.removeChild(basicEnemyShot)
        }
        enemyShotCollide = false
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, basicEnemyCrash: BasicEnemy!, basicEnemyShot: CCParticleSystem!) -> ObjCBool {
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
//        if whenEnemyDies(basicEnemyCrash) == true {//enemies need multiple hits to die.
            self.gamePhysicsNode.removeChild(shot)
            let explosion = CCBReader.load("HeroDeath") as! CCParticleSystem
            explosion.autoRemoveOnFinish = true
            explosion.position = basicEnemyCrash.position
            basicEnemyCrash.parent.addChild(explosion)
            basicEnemyCrash.removeFromParentAndCleanup(true)
            enemiesKilled++
            gameScoreLabel.string = "\(enemiesKilled)"
            enemyGone(basicEnemyCrash)
            enemies++
//        }
        heroShotCollide = true
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, basicEnemyCrash: BasicEnemy!, bossMissleCrash: CCNode!) -> ObjCBool {
        return false
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, bossMissleCrash missle1: CCNode!, bossMissleCrash missle2: CCNode!) -> ObjCBool {
        return false
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, bossMissleCrash: CCNode!, heavyTerrorCrash: HeavyTerror!) -> ObjCBool {
        return false
    }
    
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, bossMissleCrash: CCNode!, wildcard: CCNode!) {
//        println(bossMissleCrash.position)
//        println(bossMissleCrash.parent)
        if bossMissleCrash.parent != nil {
            if bossMissleCrash != nil {
                if bossMissleCrash != [] {
                    self.gamePhysicsNode.removeChild(bossMissleCrash)
                    let explosion = CCBReader.load("MissleExplosion", owner: self) as CCNode
                    explosion.position.y = (bossMissleCrash.position.y)
                    explosion.position.x = (bossMissleCrash.position.x)
                    explosion.userObject.setCompletedAnimationCallbackBlock { (sender: AnyObject!) -> Void in
                        explosion.removeFromParentAndCleanup(true)
                        self.misslesGone++
                    }
                    gamePhysicsNode.addChild(explosion)
                }
            }
        }
    }
    
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, falling: Hero!, bossMissleCrash: CCNode!) {
        heroHurt(true)
        lifeLabel.string = "\(heroHealth)"
        if heroHealth <= 0 {
            endGame()
        }
    }
    
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, falling: Hero!, heavyTerrorCrash: HeavyTerror!) {
        heroHurt(true)
        lifeLabel.string = "\(heroHealth)"
        if heroHealth <= 0 {
            endGame()
        }
    }
    
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, shot: CCNode!, heavyTerrorCrash: HeavyTerror!) {
        bossHit = true
        self.gamePhysicsNode.removeChild(shot)
        bossHealth--
        heroShotCollide = true
        if bossHealth <= 0 {
            bossHit = false
            let explosion = CCBReader.load("BossDeath") as! CCParticleSystem
            explosion.autoRemoveOnFinish = true
            explosion.position = heavyTerrorCrash.position
            heavyTerrorCrash.parent.addChild(explosion)
            enemyNode.removeChild(heavyTerrorCrash)
            isBoss = false
            isAiming = false
            missleArray.removeAll(keepCapacity: false)
            enemiesKilled = enemiesKilled + 25
            gameScoreLabel.string = "\(enemiesKilled)"
            previousBossHealth = previousBossHealth + 5
            bossHealth = previousBossHealth
            
            temporaryBoss.isClose = false
            isShooting = false
            bosses++
            bossRate = bossRate - 5
            enemyHealthNum++
        }
    }
    
    func enemyGone(noShooting: BasicEnemy!) {
        var i = 0
        i = find(enemyArray, noShooting)!
        enemyCanShoot[i] = false
    }
    
    func whenEnemyDies(health: BasicEnemy!) -> ObjCBool {
        var i = 0
        i = find(enemyArray, health)!
        enemyHealth[i] = enemyHealth[i] - 1
        if enemyHealth[i] <= 0 {
            return true
        }
        else {
            return false
        }
    }
    
    func shoot() {
        if heroShots >= fireRateDefault && gameOver == false && isTutorial == false {
            heroShots = 0
            hero.hasShot()
            hero.isShooting = true
            let explosion = CCBReader.load("Shot") as! CCParticleSystem
            explosion.autoRemoveOnFinish = true
            explosion.position.y = (hero.position.y + 5)
            explosion.position.x = (hero.position.x + CGFloat(hero.shotMoveScale))
            gamePhysicsNode.addChild(explosion)
            explosion.physicsBody.applyImpulse(CGPoint(x: hero.shotImpulseScale, y: 0))
        }
    }
    
    func tapShoot() {
        if heroShots >= fireRateDefault && gameOver == false && isTutorial == false {
            heroShots = 0
            hero.hasShot()
            hero.isShooting = true
            let explosion = CCBReader.load("Shot") as! CCParticleSystem
            explosion.autoRemoveOnFinish = true
            explosion.position.y = (hero.position.y + 5)
            explosion.position.x = (hero.position.x + CGFloat(hero.shotMoveScale))
            gamePhysicsNode.addChild(explosion)
            explosion.physicsBody.applyImpulse(CGPoint(x: hero.shotImpulseScale, y: 0))
        }
    }
    
    func heroShot() {
        if heroShots >= fireRateDefault && gameOver == false {
            heroShots = 0
            if jumped == false {
                hero.hasShot()
            }
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
        explosionEnemy.physicsBody.applyImpulse(CGPoint(x: -30, y: 45))
    }
    
     func endGame() {
        var distance = Int(hero.position.x) / 10
        defaults.setInteger(distance, forKey: "gameDistance")
        defaults.setInteger(enemiesKilled, forKey: "gameScore")
        defaults.setInteger(enemies, forKey: "gameEnemies")
        defaults.setInteger(bosses, forKey: "gameBosses")
        defaults.setBool(true, forKey: "newValues")
        
        var totalScore = defaults.integerForKey("highscore")
        totalScore = totalScore + enemiesKilled
        defaults.setInteger(totalScore, forKey: "highscore")
        
        if hurtNode.visible == true {
            hurtNode.visible = false
        }
        
        gameOver = true
        let explosion = CCBReader.load("HeroDeath") as! CCParticleSystem
        explosion.autoRemoveOnFinish = true
        explosion.position = hero.position
        hero.removeFromParent()
        gamePhysicsNode.addChild(explosion)
        var gameEndPopover = CCBReader.load("GameOver", owner: self) as! GameOver
        gameEndPopover.setMessage(enemiesKilled)
        
        gameEndPopover.position = CGPoint(x: (CCDirector.sharedDirector().viewSize().width / 2), y: (CCDirector.sharedDirector().viewSize().height / 2))
        
        addChild(gameEndPopover)
        
        checkHighScores(defaults.integerForKey("gameDistance"), score: defaults.integerForKey("gameScore"), enemies: defaults.integerForKey("gameEnemies"), bosses: defaults.integerForKey("gameBosses"))
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
            if isTutorial == true {
                tutorial.visible = false
            }
            gameOver = true
        }
    }
    
    func playScreen() {
        gameOver = false
        pauseScreen.visible = false
        self.paused = false
        if isTutorial == true {
            tutorial.visible = true
        }
    }
    
    func retryGame() {
        gamePhysicsNode.removeAllChildrenWithCleanup(true)
        sceneArray.removeAll(keepCapacity: false)
        enemyArray.removeAll(keepCapacity: false)
        backgroundArray.removeAll(keepCapacity: false)
        enemyCanShoot.removeAll(keepCapacity: false)
        let gameplayScene = CCBReader.loadAsScene("MainScene")
        CCDirector.sharedDirector().presentScene(gameplayScene)
    }
    
    func mainMenuScreen() {
        CCDirector.sharedDirector().presentScene(mainMenu)
    }
    
    func tutorialScreen() {
        addChild(tutorial)
        isTutorial = true
    }
    
    func resetDefaults() {
        defaults.setInteger(150, forKey: "speed")
        defaults.setInteger(15, forKey: "rate")
        defaults.setInteger(1, forKey: "life")
        
        defaults.setInteger(5, forKey: "speedLabel")
        defaults.setInteger(5, forKey: "rateLabel")
        defaults.setInteger(5, forKey: "lifeLabel")
        defaults.setInteger(0, forKey: "highscore")
        
        defaults.setInteger(0, forKey: "distanceTotal")
        defaults.setInteger(0, forKey: "scoreTotal")
        defaults.setInteger(0, forKey: "enemiesTotal")
        defaults.setInteger(0, forKey: "bossesTotal")
        
        defaults.setInteger(0, forKey: "distance")
        defaults.setInteger(0, forKey: "score")
        defaults.setInteger(0, forKey: "enemies")
        defaults.setInteger(0, forKey: "bosses")
        
        defaults.setInteger(0, forKey: "gameDistance")
        defaults.setInteger(0, forKey: "gameScore")
        defaults.setInteger(0, forKey: "gameEnemies")
        defaults.setInteger(0, forKey: "gameBosses")
        defaults.setBool(false, forKey: "newValues")
    }
    
    func heroHurt(direction: Bool) {
        heroHealth--
        hurtNode.visible = true
        if direction == true {
            hero.physicsBody.velocity = CGPoint(x: -100, y: 100)
        }
        else {
            hero.physicsBody.velocity = CGPoint(x: 100, y: 100)
        }
        isHurt = 0
    }
    
    func checkHighScores(heroY: Int, score: Int, enemies: Int, bosses: Int) {
        if defaults.integerForKey("distance") < heroY {
            defaults.setInteger(heroY, forKey: "distance")
        }
        if defaults.integerForKey("score") < score {
            defaults.setInteger(score, forKey: "score")
        }
        if defaults.integerForKey("enemies") < enemies {
            defaults.setInteger(enemies, forKey: "enemies")
        }
        if defaults.integerForKey("bosses") < bosses {
            defaults.setInteger(bosses, forKey: "bosses")
        }
        var totalDistance = defaults.integerForKey("distanceTotal") + heroY
        defaults.setInteger(totalDistance, forKey: "distanceTotal")
        var totalScore = defaults.integerForKey("scoreTotal") + score
        defaults.setInteger(totalScore, forKey: "scoreTotal")
        var totalEnemies = defaults.integerForKey("enemiesTotal") + enemies
        defaults.setInteger(totalEnemies, forKey: "enemiesTotal")
        var totalBosses = defaults.integerForKey("bossesTotal") + bosses
        defaults.setInteger(totalBosses, forKey: "bossesTotal")
    }
    
    func howPlay() {
        pauseScreen.visible = false
        explainScreen.visible = true

    }
    
    func backToPause() {
        pauseScreen.visible = true
        explainScreen.visible = false
    }
}