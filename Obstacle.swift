//
//  Obstacle.swift
//  AngryTimberyBird
//
//  Created by Otavio Monteagudo on 7/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation;

class Obstacle:CCNode {
    /* linked objects */
    weak var upperPipe:CCNode!;
    weak var bottomPipe:CCNode!;
    weak var goal:Goal!;
    
    /* custom variables */
    let bottomPipeMinimumPositionY:CGFloat = 182;
    //let bottomPipeMaximumPositionY:Int = 287; // maximum position + 1 do adjust to uninclusive range standards.
    //let pipeDistance:CGFloat = 196; // the total goal size.
    let bottomDiffMinMax:UInt32 = 265; // difference between minimum and maximum sizes PLUS ground size.. Minimum size will be added to it to effectively generate randomness in a range.
    
    let upperPipeMaximumPositionY:CGFloat = 184;
    
    /* cocos2d methods */
    func didLoadFromCCB() {
        // enables collision detection.
        self.upperPipe.physicsBody.sensor = true;
        self.bottomPipe.physicsBody.sensor = true;
        //self.goal.physicsBody.sensor = true;
    }
    
    /* custom methods */
    
    func setupRandomPosition() {
        //let random = CGFloat(arc4random_uniform(self.bottomDiffMinMax) + self.bottomPipeMinimumPositionY);
        let random = CGFloat(arc4random_uniform(self.bottomDiffMinMax));
        //
        self.bottomPipe.position = ccp(0, self.bottomPipeMinimumPositionY + random);
        self.upperPipe.position = ccp(0, self.upperPipeMaximumPositionY - random);
        //self.goal.position = ccp(77, self.bottomPipe.position.y);
    }
}
