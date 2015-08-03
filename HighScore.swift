//
//  HighScore.swift
//  ThreeManArmy
//
//  Created by Daniel Rubin on 7/27/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class HighScore: CCNode {
    
    weak var distanceHigh: CCLabelTTF!
    weak var scoreHigh: CCLabelTTF!
    weak var enemiesHigh: CCLabelTTF!
    weak var bossesHigh: CCLabelTTF!
    
    weak var distanceTotal: CCLabelTTF!
    weak var scoreTotal: CCLabelTTF!
    weak var enemiesTotal: CCLabelTTF!
    weak var bossesTotal: CCLabelTTF!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    func didLoadFromCCB() {
        self.contentSize = CGSize(width: CCDirector.sharedDirector().viewSize().width, height: CCDirector.sharedDirector().viewSize().height)
        var startDistance = defaults.integerForKey("distance")
        distanceHigh.string = "\(startDistance)"
        var startScore = defaults.integerForKey("score")
        scoreHigh.string = "\(startScore)"
        var startEnemies = defaults.integerForKey("enemies")
        enemiesHigh.string = "\(startEnemies)"
        var startBosses = defaults.integerForKey("bosses")
        bossesHigh.string = "\(startBosses)"
        
        var startTotalOne = defaults.integerForKey("distanceTotal")
        distanceTotal.string = "\(startTotalOne)"
        
        var startTotalTwo = defaults.integerForKey("scoreTotal")
        scoreTotal.string = "\(startTotalTwo)"
        
        var startTotalThree = defaults.integerForKey("enemiesTotal")
        enemiesTotal.string = "\(startTotalThree)"
        
        var startTotalFour = defaults.integerForKey("bossesTotal")
        bossesTotal.string = "\(startTotalFour)"
        
//        if defaults.boolForKey("newValues") == true {
//            checkHighScores(defaults.integerForKey("gameDistance"), score: defaults.integerForKey("gameScore"), enemies: defaults.integerForKey("gameEnemies"), bosses: defaults.integerForKey("gameBosses"))
//            defaults.setBool(false, forKey: "newValues")
//        }
    }
    
//    func checkHighScores(heroY: Int, score: Int, enemies: Int, bosses: Int) {
//        if defaults.integerForKey("distance") < heroY {
//            defaults.setInteger(heroY, forKey: "distance")
//            distanceHigh.string = "\(heroY)"
//        }
//        if defaults.integerForKey("score") < score {
//            defaults.setInteger(score, forKey: "score")
//            scoreHigh.string = "\(score)"
//        }
//        if defaults.integerForKey("enemies") < enemies {
//            defaults.setInteger(enemies, forKey: "enemies")
//            enemiesHigh.string = "\(enemies)"
//        }
//        if defaults.integerForKey("bosses") < bosses {
//            defaults.setInteger(bosses, forKey: "bosses")
//            bossesHigh.string = "\(bosses)"
//        }
//        var totalDistance = defaults.integerForKey("distanceTotal") + heroY
//        defaults.setInteger(totalDistance, forKey: "distanceTotal")
//        distanceTotal.string = "\(totalDistance)"
//        var totalScore = defaults.integerForKey("scoreTotal") + score
//        defaults.setInteger(totalScore, forKey: "scoreTotal")
//        scoreTotal.string = "\(totalScore)"
//        var totalEnemies = defaults.integerForKey("enemiesTotal") + enemies
//        defaults.setInteger(totalEnemies, forKey: "enemiesTotal")
//        enemiesTotal.string = "\(totalEnemies)"
//        var totalBosses = defaults.integerForKey("bossesTotal") + bosses
//        defaults.setInteger(totalBosses, forKey: "bossesTotal")
//        bossesTotal.string = "\(totalBosses)"
//    }
    
    func backToStore() {
        let store = CCBReader.loadAsScene("MainMenu")
        CCDirector.sharedDirector().presentScene(store)
    }
}