//
//  Goal.swift
//  AngryTimberyBird
//
//  Created by Otavio Monteagudo on 7/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation;

class Goal:CCNode {
    func didLoadFromCCB() {
        self.physicsBody.sensor = true;
    }
}
