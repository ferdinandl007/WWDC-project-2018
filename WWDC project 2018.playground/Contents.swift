import Cocoa
import AVFoundation
import PlaygroundSupport
import SpriteKit
/*:
 # By Ferdinand Loesch 💻🌐📷
 ## Smilelefy The smile game 😁
 
 Smilelefy uses `Cocoa`, `SpriteKit`, `CIDetector` and `AVFoundation` to create a game where all you need is a smile! No hands are required throughout the game. I built this with accessibility in mind as I have a friend who is paraplegic. Therefore he cannot use his hands to interact so I came up with the solution for him to be able to play this game!
 
 
 ----
 # How to play!
 Use your Smile to change the colour of the ball. Also try to keep a neutral face if you are not planning to change the colour.
 The colour of the ball has to match the colour of the block its colliding with. To be able to remove it and gain 20 points. However if this is not the case the ball will bounce off and 10 points will be deducted.
 The goal of the game is to remove all blocks with the highest score possible.
 
 I recommend  to play the game at 70% volume to enjoy the background music and audio feedback😉
 
### Setup The Game Scene🔧

 */
class Scene: SKScene, SKPhysicsContactDelegate {
    
    // used to track the score
    private var score = 0
    
    // keeps track of how many blocks are currently present in the game
    private var blockCount = 0
    
    // set up the number of Block rows in the game
    public var rows = 3
    
    // used to see if it's difficult
    public var isDifficult = true
    
    // sets the speed in the game
    public var ballSpeed = 100
    
    // use to check if the game has started
    private var didGameStart = false
    
    // initialises the ball Node
    private var ball =  BallNode(point: CGPoint(x: 20, y: 20))
    
    // initialises the score Label node
    private let label = Label(text: "score 0",size: 65, positionX: 220, positionY: 1000)
    
    // initialises the Emoji masking your face
    public let facelabel = Label(text: "🤓",size: 500, positionX: 1920 * 0.5, positionY: 1080 * 0.5)
    
    // initialises the startLabel
    private let startLabel = Label(text: "smiled to begin 😊 ☞ 📸", size: 100, positionX: 1920 * 0.5, positionY: 1080 * 0.5)
    
/*:
----
    The didSmile method is used to trigger the color change. Or otherwise, to start the game.  we call this function from outside the class, therefore, its public so it's accessible from outside the class
     
*/
    public func didSmile() {
    
        // it checks that the game has started
        if didGameStart{
            
            // if yes change to the next colour
            ball.color = getColor(difficult: isDifficult)
            
            // played the pong sound to signalise that the colour has changed
            playSound(soudName: "pongs", scen: self)
            
        } else {
            // otherwise start the Game
            startGame()
            
            // tells the class the game has started
            didGameStart = true
            
            // presents the score label
            label.isHidden = false
            
            // hides the game started Label
            startLabel.isHidden = true
            
            // set the position of the score able to the top left corner
            label.position = CGPoint(x: 200, y: 1000)
            
            // sets the text of the score label
            label.text = "score 0"
        }
    }
    
    //  method to start the game
    private func startGame(){
        
        // sets the initial velocity of the ball
        ball.physicsBody!.velocity = CGVector(dx: 7 * ballSpeed, dy: 6 * ballSpeed)
        
        // places the blocks  on the scene as well as return the number of blocks to block count
        blockCount = addBlocks(row: rows, Difficult: isDifficult, Scene: self)
        
        // set the position of the ball to the middle of the scene
        ball.position = CGPoint(x: 0.5 * super.size.width, y: 0.5 * super.size.height)
        
        //makes the ball visible
        ball.isHidden = false
    }
    
/*:
----
    The did move to view method gets called when the class is initialized. This will set up the scene such as the physics world and will add the labels and the Ball Note to the scene.

*/
    override func didMove(to view: SKView) {
        
        // Sets the size of the scene
        super.size = CGSize(width: 1920, height: 1080)
        
        //  initialises the physics delegate of the world to the class
        super.physicsWorld.contactDelegate = self
        
        //  sets the gravity in the scene to 0
        super.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        // makes the emoji masking your face slightly transparent to blend into the background
        facelabel.alpha = 0.1
        
        // sets the position of the emoji so that it's behind everything in the scene
        facelabel.zPosition = -1
        
        // hides the score label
        label.isHidden = true
        
        // background music
        playBackgroundMusic(scene: self)
        
        //  this adds the emoji,score level and the  start label to the scene
        super.addChild(facelabel)
        super.addChild(label)
        super.addChild(startLabel)
        
        
/*:
----
    The sceneBound sets up a bounding box around the scene this is required. As otherwise the ball would just fly off and never return. So we contain the game in this box which is the same size as the scene.
         
*/
        //  initialise the bounding box as a physics body as well as give the size of the frame to it.
        let sceneBound = SKPhysicsBody(edgeLoopFrom: super.frame)
        // sets the friction to 0 so the ball does not get slow down by it.
        sceneBound.friction = 0
        //  this will make any collisions perfectly elastic
        sceneBound.restitution = 1
        //  now we add sceneBound to a scene as a physics body
        super.physicsBody = sceneBound
        
        // gets a initial colour for the ball
        ball.color = getColor(difficult: isDifficult)
        
        // hides the ball from the scene so that on game start the scene is clear  until the game actually begins
        ball.isHidden = true
        
        // add the ball to the scene as a node
        super.addChild(ball)
    }
    
    
/*:
----
    The didBeginContact method gets called when two physics bodies collided. Therefore we can use it to detect which bodies have collided. So now we can check if the blue ball has collided with the blue block. If this is the case we can remove it and add 20 points to the score. Otherwise, we can deduct 10 points from the score.
     
     

*/
    func didBegin(_ contact: SKPhysicsContact) {
        
        // this checks if the ball has made contact with the Block
        if contact.bodyA.categoryBitMask == CategoryBitMask.Ball && contact.bodyB.categoryBitMask == CategoryBitMask.Block {
            
            // now we use the object it made contact with and reassign it as a note
            let block = contact.bodyB.node as! SKSpriteNode
            
            //  now we can check if the colour of it matches the colour of the ball if yes we can proceed
            if block.color == ball.color {
                
                // remove the block from the scene
                block.removeFromParent()
                
                // add 20 points to the score
                score += 20
                
                // set the score label to the new updated score
                label.text = "score \(score)"
                
                //  play a sound for audio feedback to the user
                playSound(soudName: "PLINK", scen: self)
                
                // deduct one from the block count
                blockCount  -= 1
                
                //  check if there are no more blocks and if yes end the game!
                if blockCount == 0 {
                    
                    //  sets a new position to the score label now it will be positioned in the centre
                    label.position = CGPoint(x: 0.5 * self.size.width, y: 0.5 * self.size.height)
                    
                    //  updates the text to the label
                    label.text = "congratulations for completing your is score \(score)"
                    
                    //  said the position of the start label to 200 dots down from the centre
                    startLabel.position = CGPoint(x: 0.5 * self.size.width, y: 0.5 * self.size.height - 200)
                    
                    //  makes the start label visible
                    startLabel.isHidden = false
                    
                    //  sets  did start game two false so now the game can be restarted
                    didGameStart = false
                    
                    //  stops the ball at its current position
                    ball.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
                    
                    //  hides the ball
                    ball.isHidden = true
                }
            //  if the ball made contact with the block of a different colour
            } else {
                //  we now deduct 10 points from the score
                score -= 10
                
                //  we update the score level
                label.text = "score \(score)"
                
                //  audio feedback to the user
                playSound(soudName: "POP", scen: self)
            }
        }
    }
}
/*:
 # Playtime💻👾
 ## initialising the game
  ----
 Try changing difficult to true you will see three colours instead of two now.
 
 In addition try changing the Rows and the speed this will modify the game to make it harder or easier
 
 */
//  initialise scene
let scene = Scene()

// set difficulty level here
scene.isDifficult = false

// set the number of rows in the game
scene.rows = 3

// set the speed of the ball here!
scene.ballSpeed = 100

/*:
 #  Face and Smiled tracking
 ----
We use AV foundation and CIDetector to do the face and smile tracking.  First, we set up a capture device this is the camera on your laptop 💻.
 So that we can use the data from the camera 📸 to detect if the user is smiling or not. In addition, we track the user's mouth position to be able to mask the face with an Emoji 🤓.
 ### Class Setup🔧
 */
public class Visage: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // set up the size of the camera view  and initialise as NSView
    fileprivate var visageCameraView = NSView(frame: NSRect(x: 0.0, y: 0.0, width: 640.0, height: 480.0))
    
    // assigning the face detector as a CI detector
    fileprivate var faceDetector : CIDetector?
    
    // assigning videoDataOutputQueue as DispatchQueue which is an optional
    fileprivate var videoDataOutputQueue : DispatchQueue?
    
    // initialising output as a capture video output
    fileprivate var output = AVCaptureVideoDataOutput()
    
    // assigning the camera preview layer
    fileprivate var cameraPreviewLayer : AVCaptureVideoPreviewLayer?
    //  initialise  AVCaptureSession
    fileprivate var captureSession : AVCaptureSession = AVCaptureSession()
    
    //  initialise capture layer as CALayer
    fileprivate var captureLayer: CALayer = CALayer()
    
    //  assigning sample buffer
    fileprivate var sampleBuffers: CMSampleBuffer?
    
    // initialising the dispatch Queue used to asynchronously process the face tracking
    fileprivate let dispatchQueue = DispatchQueue(label: "com.wwdc_project_2018")
    
    //  initialising the is user smiling variable to true
    fileprivate var isSmile = true
    
    //   initialising face tracking ends  to false
    fileprivate var  faceTrackingEnds = false
    
    //  this method is called when the class is initialised
    override init() {
        super.init()
        
        //  calls the camera set up method
        self.captureSetup()
        
        //   initialising the face detection options as a dictionary
        var faceDetectorOptions : [String : AnyObject]?
        
        //  assigning faceDetectorOptions to set the accuracy high
        faceDetectorOptions = [CIDetectorAccuracy : CIDetectorAccuracyHigh as AnyObject]
        
        // Initialising the CI detector  to detect faces with  options said to high accuracy
        self.faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: faceDetectorOptions)
    }
    
   //  method used to start running the capture session
   public func beginFaceDetection() {
    
        // This starts the capture session so the camera will turn on now
        self.captureSession.startRunning()
    
        //  this starts the face tracking
        self.faceDetection()
    }
    
   // Method to end  the capture session as well as terminate the face tracking loop
   public func endFaceDetection() {
    
        //  this will stop the capture session so the camera will turn off
        self.captureSession.stopRunning()
    
        //  this terminates  the face tracking loop
        self.faceTrackingEnds = true
    }
    
    //  captures setup method  sets up everything for the life camera view
    fileprivate func captureSetup () {
        
        //  assigns  the capture device input
        var input : AVCaptureDeviceInput
        
        //  devices will represent the media capture devices  present on this machine such as cameras and mics
        let devices : [AVCaptureDevice] = AVCaptureDevice.devices()
        
            // this loop will go through all the different media capture methods on this machine
            for device in devices {
                
                //  here we check if the device can capture video and at a resolution of 640x480
                if device.hasMediaType(AVMediaType.video) && device.supportsSessionPreset(AVCaptureSession.Preset.vga640x480) {
                    do {
                        // if yes  we set up the video input
                        input = try AVCaptureDeviceInput(device: device as AVCaptureDevice) as AVCaptureDeviceInput
                        
                        // and add the input to the capture session
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
        
            //  here we specify the settings we will use to encode the input
            self.output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable as! String: Int(kCVPixelFormatType_32BGRA)]
        
            //  this will make sure that late frames will be discarded and will not clog up the frame rate
            self.output.alwaysDiscardsLateVideoFrames = true
        
            //  puts the video encoding on our video output Queue
            self.videoDataOutputQueue = DispatchQueue(label: "VideoDataOutputQueue", attributes: [])
            self.output.setSampleBufferDelegate(self, queue: self.videoDataOutputQueue!)
        
            //  now we add our output to are captureSession
            if captureSession.canAddOutput(output) {
                captureSession.addOutput(output)
            }
        
            //   assigning capture layer  to our life video  capture layer
            self.captureLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
            //  makes sure  that visageCameraView  has a layer so we can  later  apply to life video to it
            visageCameraView.wantsLayer = true
        
            //  assigning are life video view to visageCameraView
            visageCameraView.layer = captureLayer
    }
    
    //  this method is called  during every frame
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection){
        
        //  assigning a sample buffer  to the current captured  sample buffer so we can use it later
        self.sampleBuffers = sampleBuffer
    }
    
   
 
/*:
----
    face detection method is called in a loop, asynchronously. Here we use CI Detector to analyze the video output for faces, and check if that face is smiling 😆, in addition, we also check for the position of the mouth 🤔. So that we are able to mask your face with the Emoji 🤯.
*/
    fileprivate func faceDetection(){
    
        // setting up dispatchQueue
        dispatchQueue.async {
            
            //  checking if sample buffer  is equal to nil if not assign its value to sample
            if let sample = self.sampleBuffers {
                
                //  casting the sample buffer to CMSampleBuffer and assigning it to pixelBuffer
                let pixelBuffer = CMSampleBufferGetImageBuffer(sample)
                let attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sample, kCMAttachmentMode_ShouldPropagate)
                
                //  converting the pixel buffer to an CIimage
                let ciImage = CIImage(cvImageBuffer: pixelBuffer!, options: attachments as! [String : Any]?)
                
                //  setting up the options  for the  CI detector
                let options: [String : Any] = [CIDetectorImageOrientation: 1 , CIDetectorSmile: true ,CIDetectorEyeBlink: true]
                
                //  assign an instance of CIdetector to allFeatures and initialise with the CIimage as well as the options
                let allFeatures = self.faceDetector?.features(in: ciImage, options: options)
                
                //   if allfeatures is not equal to nil. if yes assign allfeatures to features otherwise return
                guard let features = allFeatures else { return }
                
                // loop to cycle through all features
                for  feature in features {
                    
                    // checks if the feature is a CIFaceFeature if yes assign feature to face feature and go on.
                    if let faceFeature = feature as? CIFaceFeature {
/*:
----
    Get the  face label from the scene  and animate to the mouth position this will ensure that the  label will stay above the user's face.
*/
                        scene.facelabel.run(SKAction.move(to: CGPoint(x: faceFeature.mouthPosition.x + 300, y: faceFeature.mouthPosition.y + 300), duration: 0.07))
/*:
 ----
    the following tew (if gates) ensure that the isSmiling method in the scene  is only triggered once per smile  this makes the game playable without spontaneous colour change when the user keeps on smiling
 */
                        // Checks if  a smile is equal to  the user's smile
                        if self.isSmile == faceFeature.hasSmile {
                        
                            if self.isSmile {
                                
                                //  set isSmile to false
                                self.isSmile = false
                                
                                //  calling the did smile method in the game scene
                                scene.didSmile()
                                
                                //   updates the emoji label to 😆
                                scene.facelabel.text = "😆"
                                
                            // otherwise
                            } else {
                                
                                // sets isSmile to false
                                self.isSmile = true
                                
                                // updates the emoji label to 🤓
                                scene.facelabel.text = "🤓"
                                
                            }
                        }
                    }
                }
            }
            
            // checks if face detection should be terminated
            if !self.faceTrackingEnds{
            self.faceDetection()
            }
        }
    }
}// end of class
/*:
 #  Live cameras view to an NSView
 ----
Here we configure the output from the Visage Class to an NSView.
So that we can later use the live camera feed as a background to are game.
 ### Class Setup🔧
 */
class SmileView: NSView {
    
    // initialising the NSView
    fileprivate let smileView = NSView()
    
    //  assigning the Visage class to smileRec
    fileprivate var smileRec: Visage!
    
    // this method gets called when the class is initialised
    override init(frame: CGRect) {
        
        //  gets the size of the frame from the initialiser
        super.init(frame: frame)
        
        //  adds are smileView as a Subview of NSView
        self.addSubview(smileView)
        
        //  sets up constraints
        self.translatesAutoresizingMaskIntoConstraints = false
        
        //  initialising the Visage class
        smileRec = Visage()
        
        //  starts the camera view and  face tracking
        smileRec.beginFaceDetection()
        
        //  gets the  life  view from the visage class
        let cameraView = smileRec.visageCameraView
        
        //  this will  add our life camera view (cameraView) and will add it as a subview to are class
        self.addSubview(cameraView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



/*:
----
 # Now to the final setup🎉🎉😊
*/

//  the frame will set the size of a scene  with a size off 640x360
let frame = CGRect(x: 0, y: 0, width: 640.0, height: 360)

// Sets the size of our sview  as well as initialiser's SView  with SmileView
let sView = SmileView(frame: frame)

// Sets the opacity of our camera view. Try changing it to make the camera view more or less opaque
sView.alphaValue = 0.04

//  sets the aspect of the view to fill
scene.scaleMode = .aspectFit

//  initial eyes is SKView to view  and set the size to 640x360  we get this value from frame
let view = SKView(frame: frame)

//  now we present our scene in a newly created view
view.presentScene(scene)

//  and we add sView as a subview of view
view.addSubview(sView)

// now all we have to do is set the execution mode of the  playground to indefinite
PlaygroundPage.current.needsIndefiniteExecution = true

//  and are view to the playground
PlaygroundPage.current.liveView = view
/*:
 ----
 # Done! 🚀 🌍 🌎
  ----
 */
