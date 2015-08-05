//
//  About.swift
//  ThreeManArmy
//
//  Created by Daniel Rubin on 8/4/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class About: CCNode {
    
    func backToStore() {
        let mainMenu = CCBReader.loadAsScene("MainMenu")
        CCDirector.sharedDirector().presentScene(mainMenu)
        self.removeFromParentAndCleanup(true)
    }
}