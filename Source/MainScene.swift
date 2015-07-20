import Foundation;

class MainScene: CCNode {
    /* linked objects */
    
    // the bird sprite
    weak var bird:CCSprite!;
    
    // first ground; first and second grounds will be rendered one after another to give the impression of movement.
    weak var ground1:CCSprite!;
    
    // second ground block.
    weak var ground2:CCSprite!;
    
    // the main physics node, every child of it are affected by physics.
    weak var gamePhysicsNode:CCPhysicsNode!;
    
    /* custom variables */
    
}
