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
    weak var upperPipe:CCSprite!;
    weak var bottomPipe:CCSprite!;
    weak var goal:Goal!;
    
    /* custom variables */
    var bottomPipeMinimumPositionY:CGFloat!// = 180;
    //let bottomPipeMaximumPositionY:Int = 287; // maximum position + 1 do adjust to uninclusive range standards.
    //let pipeDistance:CGFloat = 196; // the total goal size.
    var bottomDiffMinMax:CGFloat!// = 200; // difference between minimum and maximum sizes PLUS ground size.. Minimum size will be added to it to effectively generate randomness in a range.
    // screen size minus groundblock size.
    var screenHeight:CGFloat!;
    var groundBlockHeight:CGFloat!;
    var upperPipeMaximumPositionY:CGFloat!// = 130;
    
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
        let random = CGFloat(arc4random_uniform(UInt32(self.screenHeight - self.groundBlockHeight - self.bottomDiffMinMax)));
        //
        self.upperPipe.position = ccp(0, random + self.groundBlockHeight + self.bottomDiffMinMax);
        self.bottomPipe.position = ccp(0, random + self.groundBlockHeight);
        //self.goal.position = self.bottomPipe.position;
        //self.goal.position = ccp(77, self.bottomPipe.position.y);
    }
    
    func setSprite(sprite: String) {
        self.upperPipe.spriteFrame = CCSpriteFrame(imageNamed: "iPad/worlds/" + sprite + "/upperPipe4.png");
        self.bottomPipe.spriteFrame = CCSpriteFrame(imageNamed: "iPad/worlds/" + sprite + "/pipe4.png");
    }
    
    func setupPositionPoints(groundBlockHeight: CGFloat, screenHeight: CGFloat) {
        //self.bottomPipeMinimumPositionY = groundBlockHeight;
        //self.upperPipeMaximumPositionY = screenHeight;
        self.groundBlockHeight = groundBlockHeight;
        self.screenHeight = screenHeight;
        self.bottomDiffMinMax = self.screenHeight * 0.35;
    }
}
