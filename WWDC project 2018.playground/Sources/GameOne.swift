
import SpriteKit


public struct CategoryBitMask {
    static let Ball: UInt32 = 0b1 << 0
    static let Block: UInt32 = 0b1 << 1
}


//

private var num = 0
public func getColor() -> SKColor {
    switch num {
    case 0:
        num = 1
        return SKColor(red: 193 / 255, green: 52 / 255, blue: 155 / 255, alpha: 1)
    case 1:
        num = 0
        return SKColor(red: 76 / 255, green: 191 / 255, blue: 86 / 255, alpha: 1)
    default:
        return SKColor(red: 193 / 255, green: 52 / 255, blue: 155 / 255, alpha: 1)
    }
}

public func playSound(soudName: String,scen: SKScene){
    let sound = SKAction.playSoundFileNamed(soudName, waitForCompletion: false)
    scen.run(sound)
}


public func BallNode(point: CGPoint) -> SKSpriteNode {
    let ball = SKSpriteNode(color: SKColor.white, size: CGSize(width: 50, height: 50))
    ball.physicsBody = SKPhysicsBody(rectangleOf: ball.size)
    ball.physicsBody!.allowsRotation = false
    ball.physicsBody!.categoryBitMask = CategoryBitMask.Ball
    ball.physicsBody!.contactTestBitMask = CategoryBitMask.Block
    ball.physicsBody!.friction = 0
    ball.physicsBody!.linearDamping = 0
    ball.physicsBody!.restitution = 1
    ball.physicsBody!.velocity = CGVector(dx: 500, dy: 400)
    ball.position = point
    return ball
    
}

public func Label(text: String,positionX: CGFloat,positionY: CGFloat) -> SKLabelNode{
    let label = SKLabelNode(fontNamed: "Chalkduster")
    label.text = text
    label.fontSize = 65
    label.fontColor = SKColor.white
    label.position = CGPoint(x: positionX, y: positionY)
    return label
}

public func BlockNode() -> SKSpriteNode {
    let block = SKSpriteNode(color: SKColor.white, size: CGSize(width: 150, height: 50))
    block.name = "Block"
    block.physicsBody = SKPhysicsBody(rectangleOf: block.size)
    block.physicsBody!.categoryBitMask = CategoryBitMask.Block
    block.physicsBody!.isDynamic = false
    block.physicsBody!.friction = 0
    block.physicsBody!.restitution = 1
    return block
}


