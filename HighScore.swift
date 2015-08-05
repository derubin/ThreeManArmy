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
    
    func backToStore() {
        let store = CCBReader.loadAsScene("MainMenu")
        CCDirector.sharedDirector().presentScene(store)
    }
}