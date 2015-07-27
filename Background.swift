//
//  Background.swift
//  AngryTimberyBird
//
//  Created by Otavio Monteagudo on 7/27/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation;

class Background:CCNode {
    /* linked objects */
    // the actual image which represents that section of background.
    var backgroundSprite:CCSprite!;
    // the sensor
    var bgSensor:CCNode!;
    // node located just at the end of the background's sprite frame; it'll be a sensor which will change the obstacle position once the bird triggers it.
    func didLoadFromCCB() {
        self.bgSensor.physicsBody.sensor = true;
    }
}
