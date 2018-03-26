import Cocoa
import AVFoundation
import PlaygroundSupport
import SpriteKit


/*:
 # Ferdinand Loesch♦️🔵🔶
 ## The music-lovin' kaleidoscope.
 
 Kaleido uses `CAReplicatorLayers`, masks, `CoreAnimation` and `AVFoundation` to create a kaleidoscope visualizer that reacts to the beat of your favorite tracks.
 
 ----
 
 ### Setup 🔧
 */
//#-hidden-code



class Scene: SKScene, SKPhysicsContactDelegate {
    
    private var score = 0
    private var blockCount = 0
    public var rows = 3
    public var isDifficult = true
    private var didGameStart = false
    private var ball =  BallNode(point: CGPoint(x: 20, y: 20))
    private let label = Label(text: "score 0",size: 65, positionX: 220, positionY: 1000)
    public let facelabel = Label(text: "🤓",size: 500, positionX: 1920 * 0.5, positionY: 1080 * 0.5)
    private let startLabel = Label(text: "smiled to begin 😊 ☞ 📸", size: 100, positionX: 1920 * 0.5, positionY: 1080 * 0.5)
    
    
     func didSmile() {
        if didGameStart{
            ball.color = getColor(difficult: isDifficult)
            playSound(soudName: "pongs", scen: self)
        } else {
            startGame()
            didGameStart = true
            label.isHidden = false
            startLabel.isHidden = true
            label.position = CGPoint(x: 200, y: 1000)
            label.text = "score 0"
        }
    }
    
    private func startGame(){
        ball.physicsBody!.velocity = CGVector(dx: 700, dy: 600)
        blockCount = addBlocks(row: rows, Difficult: isDifficult, Scene: self)
        ball.isHidden = false
    }
    
    
    
    override func didMove(to view: SKView) {
        super.size = CGSize(width: 1920, height: 1080)
        
        super.physicsWorld.contactDelegate = self
        
        super.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        facelabel.alpha = 0.1
        facelabel.zPosition = -1
        label.isHidden = true
        super.addChild(facelabel)
        super.addChild(label)
        super.addChild(startLabel)
        
        let sceneBound = SKPhysicsBody(edgeLoopFrom: super.frame)
        sceneBound.friction = 0
        sceneBound.restitution = 1
        super.physicsBody = sceneBound
        
        
        ball.position = CGPoint(x: 0.5 * super.size.width, y: 0.5 * super.size.height)
        super.addChild(ball)
        ball.color = getColor(difficult: isDifficult)
        ball.isHidden = true
        
       
        
    }
    
    

    
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == CategoryBitMask.Ball && contact.bodyB.categoryBitMask == CategoryBitMask.Block {
            let block = contact.bodyB.node as! SKSpriteNode
            if block.color == ball.color {
                block.removeFromParent()
                print(blockCount)
                score += 20
                label.text = "score \(score)"
                playSound(soudName: "PLINK", scen: self)
                blockCount  -= 1
                if blockCount == 0 {
                    label.position = CGPoint(x: 0.5 * self.size.width, y: 0.5 * self.size.height)
                    label.text = "congratulations for completing your is score \(score)"
                    startLabel.position = CGPoint(x: 0.5 * self.size.width, y: 0.5 * self.size.height - 200)
                    startLabel.isHidden = false
                    blockCount = 0
                    didGameStart = false
                    ball.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
                    ball.isHidden = true
                    
                }
            } else {
                score -= 10
                label.text = "score \(score)"
                playSound(soudName: "POP", scen: self)
            }
        }
    }
}










let scene = Scene()
scene.isDifficult = false
scene.rows = 1

public class Visage: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    fileprivate var visageCameraView = NSView(frame: NSRect(x: 0.0, y: 0.0, width: 640.0, height: 480.0))
    fileprivate var faceDetector : CIDetector?
    fileprivate var videoDataOutputQueue : DispatchQueue?
    fileprivate var output = AVCaptureVideoDataOutput()
    fileprivate var cameraPreviewLayer : AVCaptureVideoPreviewLayer?
    fileprivate var captureSession : AVCaptureSession = AVCaptureSession()
    fileprivate let notificationCenter : NotificationCenter = NotificationCenter.default
    fileprivate var captureLayer: CALayer = CALayer()
    fileprivate var sampleBuffers: CMSampleBuffer?
    fileprivate let dispatchQueue = DispatchQueue(label: "com.wwdc_project_2018")
    
    
    fileprivate var isSmile = true
    fileprivate var images = [NSImage]()
    
    override init() {
        super.init()
        
        self.captureSetup()
        var faceDetectorOptions : [String : AnyObject]?
        faceDetectorOptions = [CIDetectorAccuracy : CIDetectorAccuracyHigh as AnyObject]
        self.faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: faceDetectorOptions)
    }
    
   public func beginFaceDetection() {
        self.captureSession.startRunning()
        
    }
    
   public func endFaceDetection() {
        self.captureSession.stopRunning()
        
    }
    
 
  
    fileprivate func captureSetup () {
        var input : AVCaptureDeviceInput
        let devices : [AVCaptureDevice] = AVCaptureDevice.devices()
            for device in devices {
                if device.hasMediaType(AVMediaType.video) && device.supportsSessionPreset(AVCaptureSession.Preset.vga640x480) {
                    do {
                        input = try AVCaptureDeviceInput(device: device as AVCaptureDevice) as AVCaptureDeviceInput
                        
                        if captureSession.canAddInput(input) {
                            captureSession.addInput(input)
                            break
                        }
                    }
                    catch {
                        error
                    }
                }
            }
           

            
            
            self.output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable as! String: Int(kCVPixelFormatType_32BGRA)]
            self.output.alwaysDiscardsLateVideoFrames = true
            self.output.alwaysDiscardsLateVideoFrames = true
            self.videoDataOutputQueue = DispatchQueue(label: "VideoDataOutputQueue", attributes: [])
            self.output.setSampleBufferDelegate(self, queue: self.videoDataOutputQueue!)
            
            if captureSession.canAddOutput(output) {
                captureSession.addOutput(output)
            }
            
            self.captureLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            visageCameraView.wantsLayer = true
            visageCameraView.layer = captureLayer
            
        
    }
    
    
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection){
        self.sampleBuffers = sampleBuffer
    }
    
   
 
    
   public func faceDetection(){
        dispatchQueue.async {
            if let sample = self.sampleBuffers {
                
                let pixelBuffer = CMSampleBufferGetImageBuffer(sample)
                let attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sample, kCMAttachmentMode_ShouldPropagate)
                let ciImage = CIImage(cvImageBuffer: pixelBuffer!, options: attachments as! [String : Any]?)
                let options: [String : Any] = [CIDetectorImageOrientation: 1 , CIDetectorSmile: true ,CIDetectorEyeBlink: true]
                let allFeatures = self.faceDetector?.features(in: ciImage, options: options)
                
                
                guard let features = allFeatures else { return }
                
                for feature in features {
                    if let faceFeature = feature as? CIFaceFeature {
                      //  let featureDetails = ["has smile: \(faceFeature.hasSmile)",
                          //  "has closed left eye: \(faceFeature.leftEyeClosed)",
                           // "has closed right eye: \(faceFeature.rightEyeClosed)"]
                      
                        scene.facelabel.run(SKAction.move(to: CGPoint(x: faceFeature.mouthPosition.x + 300, y: faceFeature.mouthPosition.y + 300), duration: 0.07))
                        
                        if self.isSmile == faceFeature.hasSmile {
                            if self.isSmile {
                                self.isSmile = false
                                scene.didSmile()
                                scene.facelabel.text = "😆"
                                print("the user isSmile")
                                
                            } else {
                                self.isSmile = true
                                scene.facelabel.text = "🤓"
                                
                            }
                        }
                    }
                }//end of loop
            }//end of if let sample = self.sampleBuffers
            
            self.faceDetection()
        }
    }// end func
    
    
}// end of class




//#-end-hidden-code

class SmileView: NSView {
    fileprivate let smileView = NSView()
    fileprivate var smileRec: Visage!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(smileView)
        self.translatesAutoresizingMaskIntoConstraints = false
        //#-editable-code
        smileRec = Visage()
        smileRec.beginFaceDetection()
        smileRec.faceDetection()
        //#-end-editable-code
        
        
        let cameraView = smileRec.visageCameraView
        
        self.addSubview(cameraView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

let frame = CGRect(x: 0, y: 0, width: 640.0, height: 360)
let sView = SmileView(frame: frame)
sView.alphaValue = 0.04


scene.scaleMode = .aspectFit

let view = SKView(frame: NSRect(x: 0, y: 0, width: 640, height: 360))
view.presentScene(scene)
view.addSubview(sView)




PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = view


