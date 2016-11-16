import SpriteKit

class MainMenuScene: SKScene {
    
    var playBtn = SKSpriteNode();
    var scoreBtn = SKSpriteNode();
    
    var title = SKLabelNode();
    
    var scoreLabel = SKLabelNode();
    
    override func didMove(to view: SKView) {
        initialize();
    }
    
    override func update(_ currentTime: TimeInterval) {
        moveBackgroundsAndGrounds();
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let location = touch.location(in: self);
            
            if atPoint(location) == playBtn {
                let gameplay = GameplayScene(fileNamed: "GameplayScene");
                gameplay!.scaleMode = .aspectFill
                self.view?.presentScene(gameplay!, transition: SKTransition.doorway(withDuration: TimeInterval(1.5)));
            }
            
            if atPoint(location) == scoreBtn {
                // show the highscore
                showScore();
            }
            
        }
        
    }
    
    func initialize() {
        createBG();
        createGrounds();
        getButtons();
        getLabel();
    }
    
    func createBG() {
        for i in 0...2 {
            let bg = SKSpriteNode(imageNamed: "BG");
            bg.name = "BG";
            bg.anchorPoint = CGPoint(x: 0.5, y: 0.5);
            bg.position = CGPoint(x: CGFloat(i) * bg.size.width, y: 50);
            bg.zPosition = 0;
            self.addChild(bg);
        }
    }
    
    func createGrounds() {
        for i in 0...2 {
            let bg = SKSpriteNode(imageNamed: "Ground");
            bg.name = "Ground";
            bg.anchorPoint = CGPoint(x: 0.5, y: 0.5);
            bg.position = CGPoint(x: CGFloat(i) * bg.size.width, y: -(self.frame.size.height / 2));
            bg.zPosition = 3;
            self.addChild(bg);
        }
    }

    func moveBackgroundsAndGrounds() {
        
        enumerateChildNodes(withName: "BG", using: ({
            (node, error) in
            
            let bgNode = node as! SKSpriteNode;
            
            bgNode.position.x -= 4;
            
            if bgNode.position.x < -(self.frame.width) {
                bgNode.position.x += bgNode.size.width * 3;
            }
            
        }));
        
        enumerateChildNodes(withName: "Ground", using: ({
            (node, error) in
            
            let bgNode = node as! SKSpriteNode;
            
            bgNode.position.x -= 2;
            
            if bgNode.position.x < -(self.frame.width) {
                bgNode.position.x += bgNode.size.width * 3;
            }
            
        }));
        
    }
    
    func getButtons() {
        playBtn = self.childNode(withName: "Play") as! SKSpriteNode;
    }
    
    func getLabel() {
        title = self.childNode(withName: "Title") as! SKLabelNode;
        
        title.fontName = "Helvetica";
        title.fontSize = 120;
        title.text = "OfficeRunner";
        
        title.zPosition = 5;
        
        let moveUp = SKAction.moveTo(y: title.position.y + 50, duration: TimeInterval(1.3));
        
        let moveDown = SKAction.moveTo(y: title.position.y - 50, duration: TimeInterval(1.3));
        
        let sequence = SKAction.sequence([moveUp, moveDown]);
        
        title.run(SKAction.repeatForever(sequence));
        
    }
    
    func showScore() {
        scoreLabel.removeFromParent();
        
        scoreLabel = SKLabelNode(fontNamed: "RosewoodStd-Regular");
        scoreLabel.fontSize = 180;
        scoreLabel.text = "\(UserDefaults.standard.integer(forKey: "Highscore"))";
        scoreLabel.position = CGPoint(x: 0, y: -200);
        scoreLabel.zPosition = 9;
        self.addChild(scoreLabel);
    }
    
}
