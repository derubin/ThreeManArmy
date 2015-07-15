

import Foundation

class IdleHero: CCSprite {
    
    //var hero = CCBReader.load("IdleHero") as!
    //var side: Side = .Left
    
    func left() {
        println("LEFT")
        //hero?.position = CGPoint(x: 25, y: 125)
        //side = .Left
        //scaleX = 1
        //scaleXInPoints
    }
    
    func right() {
        println("RIGHT")
        //hero?.position = CGPoint(x: 500, y: 125)
        //side = .Right
        //scaleX = -1
    }
}