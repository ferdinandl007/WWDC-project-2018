
import SpriteKit

// struct To store  the  category bit masks
public struct CategoryBitMask {
    public static let Ball: UInt32 = 0b1 << 0
    public static let Block: UInt32 = 0b1 << 1
}



//  this method  returns  the next colour  in the switch statement
public var num = 0
public func getColor(difficult: Bool) -> SKColor {
    switch num {
    case 0:
        num = 1
        return SKColor(red: 193 / 255, green: 52 / 255, blue: 155 / 255, alpha: 1)
    case 1:
        if difficult{
            num = 2
        } else{
            num = 0
        }
        return SKColor(red: 76 / 255, green: 191 / 255, blue: 86 / 255, alpha: 1)
        
    case 2:
        num = 0
        return SKColor(red: 0, green: 175 / 255, blue: 202 / 255, alpha: 1)
    default:
        return SKColor(red: 193 / 255, green: 52 / 255, blue: 155 / 255, alpha: 1)
    }
}


//   method to play the sound
public func playSound(soudName: String,scen: SKScene){
    let sound = SKAction.playSoundFileNamed(soudName, waitForCompletion: false)
    scen.run(sound)
}

// method to Play background music
public func playBackgroundMusic(scene: SKScene){
    scene.run(SKAction.repeatForever(SKAction.playSoundFileNamed("song", waitForCompletion: true)))
}


//  method to return a ball note already configured
public func BallNode(point: CGPoint) -> SKSpriteNode {
    let ball = SKSpriteNode(color: SKColor.white, size: CGSize(width: 50, height: 50))
    
    ball.physicsBody = SKPhysicsBody(rectangleOf: ball.size)
    ball.physicsBody!.allowsRotation = false
    ball.physicsBody!.categoryBitMask = CategoryBitMask.Ball
    ball.physicsBody!.contactTestBitMask = CategoryBitMask.Block
    ball.physicsBody!.friction = 0
    ball.physicsBody!.linearDamping = 0
    ball.physicsBody!.restitution = 1
    ball.position = point
    return ball
    
}

//  method  to set up  the block blockade
public func addBlocks(row: Int,Difficult: Bool, Scene: SKScene) -> Int {
    
    var blockCount = 0
    let block = SKSpriteNode(color: SKColor.white, size: CGSize(width: 150, height: 50))
    
    block.name = "Block"
    block.physicsBody = SKPhysicsBody(rectangleOf: block.size)
    block.physicsBody!.categoryBitMask = CategoryBitMask.Block
    block.physicsBody!.isDynamic = false
    block.physicsBody!.friction = 0
    block.physicsBody!.restitution = 1
 
    for y in 1...row {
        for x in 1...11 {
            let b = block.copy() as! SKSpriteNode
            b.position = CGPoint(x: (b.size.width + 10) * CGFloat(x), y: (b.size.height + 10) * CGFloat(y))
            b.color = getColor(difficult: Difficult)
            Scene.addChild(b)
            blockCount += 1
            
        }
    }
    return blockCount
}


// method to return a configured label
public func Label(text: String,size: CGFloat,positionX: CGFloat,positionY: CGFloat) -> SKLabelNode{
    let label = SKLabelNode(fontNamed: "Helvetica-Bold")
    label.text = text
    label.fontSize = size
    label.fontColor = SKColor.white
    label.position = CGPoint(x: positionX, y: positionY)
    return label
}



