//
//  Pig.swift
//  AngryTimberyBird
//
//  Created by Otavio Monteagudo on 7/21/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation;

class Pig:CCSprite {
    
    func didLoadFromCCB() {
        self.physicsBody.sensor = true;
    }
    
    func die() {
        animationManager.runAnimationsForSequenceNamed("Die");
    }
    
    func revive() {
        animationManager.runAnimationsForSequenceNamed("FlapWings");
    }
}
