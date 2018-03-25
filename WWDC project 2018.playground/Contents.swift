import Cocoa
import AVFoundation
import AVKit
import QuartzCore
import PlaygroundSupport
import AudioToolbox
import SpriteKit


/*:
 # Kaleido♦️🔵🔶
 ## The music-lovin' kaleidoscope.
 
 Kaleido uses `CAReplicatorLayers`, masks, `CoreAnimation` and `AVFoundation` to create a kaleidoscope visualizer that reacts to the beat of your favorite tracks.
 
 ----
 
 ### Setup 🔧
 */
//#-hidden-code



class Scene: SKScene, SKPhysicsContactDelegate {
    
    struct CategoryBitMask {
        static let Ball: UInt32 = 0b1 << 0
        static let Block: UInt32 = 0b1 << 1
    }
    
    
    
    
    var score = 0
    
    var ball =  BallNode(point: CGPoint(x: 20, y: 20))
    let label = Label(text: "score 0", positionX: 220, positionY: 1000)
    
    func didSmile() {
        ball.color = getColor()
        playSound(soudName: "pongs", scen: self)
    }
    
    
    override func didMove(to view: SKView) {
        super.size = CGSize(width: 1920, height: 1080)
        
        super.physicsWorld.contactDelegate = self
        
        super.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        
        super.addChild(label)
        
        let sceneBound = SKPhysicsBody(edgeLoopFrom: super.frame)
        sceneBound.friction = 0
        sceneBound.restitution = 1
        super.physicsBody = sceneBound
        
        
        ball.position = CGPoint(x: 0.5 * super.size.width, y: 0.5 * super.size.height)
        
        
        ball.color = getColor()
        
        super.addChild(ball)
        
        let block = BlockNode()
        
        for y in 1...3 {
            for x in 1...11 {
                let b = block.copy() as! SKSpriteNode
                b.position = CGPoint(x: (b.size.width + 10) * CGFloat(x), y: (b.size.height + 10) * CGFloat(y))
                b.color = getColor()
                super.addChild(b)
            }
        }
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == CategoryBitMask.Ball && contact.bodyB.categoryBitMask == CategoryBitMask.Block {
            let block = contact.bodyB.node as! SKSpriteNode
            if block.color == ball.color {
                block.removeFromParent()
                score += 20
                label.text = "score \(score)"
                playSound(soudName: "PLINK", scen: self)
                
            } else {
                score -= 10
                label.text = "score \(score)"
                playSound(soudName: "POP", scen: self)
            }
        }
    }
}










let scene = Scene()

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
    fileprivate let dispatchQueueML = DispatchQueue(label: "com.hw.dispatchqueueml")
    
    fileprivate var isSmile = true
    
    
    
    override init() {
        super.init()
        
        self.captureSetup()
        var faceDetectorOptions : [String : AnyObject]?
        faceDetectorOptions = [CIDetectorAccuracy : CIDetectorAccuracyHigh as AnyObject]
        self.faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: faceDetectorOptions)
    }
    
    func beginFaceDetection() {
        self.captureSession.startRunning()
        
    }
    
    func endFaceDetection() {
        self.captureSession.stopRunning()
    }
    
    
    fileprivate func captureSetup () {
        var input : AVCaptureDeviceInput
        if let devices : [AVCaptureDevice] = AVCaptureDevice.devices() as? [AVCaptureDevice] {
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
    }
    
    
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection){
        self.sampleBuffers = sampleBuffer
        
    }
    
    
    func faceDetection(){
        dispatchQueueML.async {
            if let sample = self.sampleBuffers {
                
                let pixelBuffer = CMSampleBufferGetImageBuffer(sample)
                let attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sample, kCMAttachmentMode_ShouldPropagate)
                let ciImage = CIImage(cvImageBuffer: pixelBuffer!, options: attachments as! [String : Any]?)
                let options: [String : Any] = [CIDetectorImageOrientation: 1 , CIDetectorSmile: true ,CIDetectorEyeBlink: true]
                let allFeatures = self.faceDetector?.features(in: ciImage, options: options)
                
                
                guard let features = allFeatures else { return }
                
                for feature in features {
                    if let faceFeature = feature as? CIFaceFeature {
                        let featureDetails = ["has smile: \(faceFeature.hasSmile)",
                            "has closed left eye: \(faceFeature.leftEyeClosed)",
                            "has closed right eye: \(faceFeature.rightEyeClosed)"]
                        
                        if self.isSmile == faceFeature.hasSmile {
                            if self.isSmile {
                                self.isSmile = false
                                print(featureDetails)
                                
                                scene.didSmile()
                                
                            } else {
                                self.isSmile = true
                                print(featureDetails)
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

//PlaygroundPage.current.liveView = view


let frame = CGRect(x: 0, y: 0, width: 640.0, height: 360)
let sView = SmileView(frame: frame)
sView.alphaValue = 0.04





scene.scaleMode = .aspectFit

let view = SKView(frame: NSRect(x: 0, y: 0, width: 640, height: 360))
view.presentScene(scene)
view.addSubview(sView)




PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = view


