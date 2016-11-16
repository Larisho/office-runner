import SpriteKit

// struct holding the bitmasks of all colliding objects
struct ColliderType {
    static let Player: UInt32 = 1;
    static let Ground: UInt32 = 2;
    static let Obstacle: UInt32 = 3;
}

class Player: SKSpriteNode {
    
    // due to complications with SKSpriteNode's constructor, we are using a function constructor 
    // instead of a traditional constructor.
    func initialize() {
        
        // variable that holds the sprite sheet, essentially.
        var walk = [SKTexture]();
        
        // for every sprite picture, add it to the walk array.
        for i in 1...11 {
            let name = "Player \(i)";
            walk.append(SKTexture(imageNamed: name));
        }
        
        // cycle through all the sprites at approx 60 fps 
        // (to be honest, I got the number below on stack overflow)
        // and assign that animation to walkAnimation
        let walkAnimation = SKAction.animate(with: walk, timePerFrame: TimeInterval(0.064), resize: true, restore: true);
        
        self.name = "Player";
        // position of the sprite on the Z axis
        self.zPosition = 2;
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5);
        self.setScale(0.5);
        // drawing physics body
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.size.width - 20, height: self.size.height));
        self.physicsBody?.affectedByGravity = true;
        // make this false because if not, player will constantly fall flat on
        // it's face.
        self.physicsBody?.allowsRotation = false;
        // assigning it's bitmask
        self.physicsBody?.categoryBitMask = ColliderType.Player;
        // assigning which bitmasks should be treated as collisions
        self.physicsBody?.collisionBitMask = ColliderType.Ground | ColliderType.Obstacle;
        // assigning which bitmasks should be treated as normal contact
        self.physicsBody?.contactTestBitMask = ColliderType.Ground | ColliderType.Obstacle;
        
        // run the animation forever (or at least until the user loses)
        self.run(SKAction.repeatForever(walkAnimation));
    }
    
    // makes player jump. Uses impulse and momentum instead of upward force.
    func jump() {
        self.physicsBody?.velocity = CGVector(dx: 0, dy: 0);
        self.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 240));
    }
    
}
