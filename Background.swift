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
    weak var backgroundSprite:CCSprite!;
    // the sensor
    weak var bgSensor:CCNode!;
    
    /* custom variables */
    // will keep track of "real" value of the background, without taking the sensor distance in consideration.
    var backgroundWidth:CGFloat!;
    // keeps track of distance between sensor and background frame
    var sensorDistanceFromFrame:CGFloat!;
    // node located just at the end of the background's sprite frame; it'll be a sensor which will change the obstacle position once the bird triggers it.
    func didLoadFromCCB() {
        self.bgSensor.physicsBody.sensor = true;
        self.backgroundWidth = self.backgroundSprite.contentSize.width;
        self.sensorDistanceFromFrame = self.contentSize.width - self.backgroundWidth;
    }
}
