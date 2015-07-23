//
//  MainMenu.swift
//  ThreeManArmy
//
//  Created by Daniel Rubin on 7/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class MainMenu: CCNode {
    
    //10, 25, 50, 100, 250, 500, 1000
    weak var upgradeSpeedLabel: CCLabelTTF!
    weak var upgradeRateLabel: CCLabelTTF!
    weak var upgradeLifeLabel: CCLabelTTF!
    
    var speed = 0
    var rate = 0
    var life = 0
    var speedOnce = true
    var rateOnce = true
    var lifeOnce = true
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    func didLoadFromCCB() {
        var startSpeed = defaults.integerForKey("speedLabel")
        upgradeSpeedLabel.string = "\(startSpeed)"
        var startRate = defaults.integerForKey("rateLabel")
        upgradeRateLabel.string = "\(startRate)"
        var startLife = defaults.integerForKey("lifeLabel")
        upgradeLifeLabel.string = "\(startLife)"
    }
    
    func startGame() {
        let game = CCBReader.loadAsScene("MainScene")
        CCDirector.sharedDirector().presentScene(game)
        self.removeFromParentAndCleanup(true)
    }
    
    func upgradeSpeed() {
        var points = defaults.integerForKey("highscore")
        speed = defaults.integerForKey("speedLabel")
        if points >= speed {
            if speedOnce == true {
                defaults.setInteger(50, forKey: "speed")
                speedOnce = false
            }
            var newScore = defaults.integerForKey("highscore") - speed
            defaults.setInteger(newScore, forKey: "highscore")
            println(newScore)
            
            var actualSpeed = defaults.integerForKey("speed")
            speed = defaults.integerForKey("speedLabel") + 10
            actualSpeed = actualSpeed + 5
            defaults.setInteger(actualSpeed, forKey: "speed")
            upgradeSpeedLabel.string = "\(speed)"
            defaults.setInteger(speed, forKey: "speedLabel")
        }
    }
    
    func upgradeRate() {
        var points = defaults.integerForKey("highscore")
        rate = defaults.integerForKey("rateLabel")
        if points >= rate {
            if rateOnce == true {
                defaults.setInteger(100, forKey: "rate")
                rateOnce = false
            }
            var newScore = defaults.integerForKey("highscore") - rate
            defaults.setInteger(newScore, forKey: "highscore")
            println(newScore)
            
            var actualRate = defaults.integerForKey("rate")
            rate = defaults.integerForKey("rateLabel") + 10
            actualRate = actualRate - 5
            defaults.setInteger(actualRate, forKey: "rate")
            upgradeRateLabel.string = "\(rate)"
            defaults.setInteger(rate, forKey: "rateLabel")
        }
    }
    
    func upgradeLife() {
        var points = defaults.integerForKey("highscore")
        life = defaults.integerForKey("lifeLabel")
        if points >= life {
            if lifeOnce == true {
                defaults.setInteger(3, forKey: "life")
                lifeOnce = false
            }
            var newScore = defaults.integerForKey("highscore") - life
            defaults.setInteger(newScore, forKey: "highscore")
            println(newScore)
            
            life = defaults.integerForKey("lifeLabel")
            var actualLife = defaults.integerForKey("life")
            life = defaults.integerForKey("lifeLabel") + 10
            actualLife = actualLife + 1
            defaults.setInteger(actualLife, forKey: "life")
            upgradeLifeLabel.string = "\(life)"
            defaults.setInteger(life, forKey: "lifeLabel")
        }
    }
}