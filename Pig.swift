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
    
    func didLoadFromCCB() {
        self.physicsBody.sensor = true;
    }
    
    func die() {
        self.runAction(CCActionMoveBy(duration: 0.2, position: CGPoint(x: 0, y: 500)));
        animationManager.runAnimationsForSequenceNamed("Die");
    }
    
    func revive() {
        animationManager.runAnimationsForSequenceNamed("FlapWings");
    }
}
