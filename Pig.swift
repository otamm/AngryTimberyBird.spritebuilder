//
//  Pig.swift
//  AngryTimberyBird
//
//  Created by Otavio Monteagudo on 7/21/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation;

class Pig:CCSprite {
    // index of pig inside pigs array
    var index:Int!;
    // checks wheter pig was popped or not.
    var isPopped:Bool = false;
    // stores deviation from standard position.
    var distanceFromCenter:CGFloat!;
    
    func didLoadFromCCB() {
        self.physicsBody.sensor = true;
    }
    
    func die() {
        self.isPopped = true;
        self.runAction(CCActionMoveBy(duration: 0.2, position: CGPoint(x: 0, y: 500)));
        animationManager.runAnimationsForSequenceNamed("Die");
    }
    
    func revive() {
        self.isPopped = false;
        animationManager.runAnimationsForSequenceNamed("FlapWings");
    }
}
