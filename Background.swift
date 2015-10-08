//
//  Background.swift
//  AngryTimberyBird
//
//  Created by Otavio Monteagudo on 7/27/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation;

class Background:CCSprite {
    func setSprite(sprite: String) {
        self.spriteFrame = CCSpriteFrame(imageNamed: "iPad/worlds/" + sprite + "/background4.png");
    }
}
