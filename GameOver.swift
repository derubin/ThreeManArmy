//
//  GameOver.swift
//  ThreeManArmy
//
//  Created by Daniel Rubin on 7/16/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class GameOver: CCNode {
    
    weak var scoreLabel: CCLabelTTF!//for score
    
    let mainMenu = CCBReader.loadAsScene("MainMenu")
    
    func setMessage(score: Int) {
        scoreLabel.string = "\(score)"
    }
    
    func mainMenuFromEnd() {
        CCDirector.sharedDirector().presentScene(mainMenu)
    }
}