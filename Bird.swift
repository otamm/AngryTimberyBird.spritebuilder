//
//  Bird.swift
//  AngryTimberyBird
//
//  Created by Otavio Monteagudo on 7/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation;

class Bird:CCSprite {
    /* linked objects */
    
    // eyes of bird after dying
    weak var deadEye:CCSprite!;
    
    /* custom variables */
    
    /* cocos2d methods */
    func didLoadFromCCB() {
        //self.physicsBody.sensor = true;
    }
    
    /* custom methods */
    
    // makes deadEye visible.
    func die() {
        //self.deadEye.visible = true;
        let random = CCRANDOM_0_1();
        if (random > 0.5) {
            animationManager.runAnimationsForSequenceNamed("DieDown");
        } else {
            animationManager.runAnimationsForSequenceNamed("DieUp");
        }
    }
}