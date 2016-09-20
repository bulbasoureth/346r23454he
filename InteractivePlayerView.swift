/* The MIT License

    Copyright 2015 Ahmet Keskin

    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT   LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import UIKit

protocol InteractivePlayerViewDelegate {
    
    func actionOneButtonTapped(_ sender : UIButton, isSelected : Bool)
    func actionTwoButtonTapped(_ sender : UIButton, isSelected : Bool)
    func actionThreeButtonTapped(_ sender : UIButton, isSelected : Bool)
    
    func interactivePlayerViewDidStartPlaying(_ playerInteractive:InteractivePlayerView)
     func interactivePlayerViewDidStopPlaying(_ playerInteractive:InteractivePlayerView)
    
    
    /**
       @ callbacks in every changes at the duration
     */
    func interactivePlayerViewDidChangedDuration(_ playerInteractive:InteractivePlayerView , currentDuration:Double)
}

@IBDesignable
class InteractivePlayerView : UIView {
    
    var view: UIView!
    var delegate: InteractivePlayerViewDelegate?
    
    @IBOutlet fileprivate var coverImageView: UIImageView!
    @IBOutlet fileprivate var timeLabel: UILabel!
    @IBOutlet fileprivate var actionOne: UIButton!
    @IBOutlet fileprivate var actionTwo: UIButton!
    @IBOutlet fileprivate var actionThree: UIButton!
    @IBOutlet fileprivate var actionOneButtonWidth: NSLayoutConstraint!
    @IBOutlet fileprivate var actionOneButtonHeight: NSLayoutConstraint!
    @IBOutlet fileprivate var actionTwoButtonWidth: NSLayoutConstraint!
    @IBOutlet fileprivate var actionTwoButtonHeight: NSLayoutConstraint!
    @IBOutlet fileprivate var actionThreeButtonWidth: NSLayoutConstraint!
    @IBOutlet fileprivate var actionThreeButtonHeight: NSLayoutConstraint!
    
    /// duration of song
    var progress : Double = 0.0
    
    /// is music playing
    var isPlaying : Bool = false
    
    /// You can set action button images with this struct
    var actionImages = ActionButtonImages()
    
    /// set progress colors
    var progressEmptyColor : UIColor = UIColor.white
    var progressFullColor : UIColor = UIColor.red
    
    /// used to change current time of the sound . default is true
    var panEnabled:Bool = true
    
    /// is ActionOne selected
    var isActionOneSelected : Bool = false {
        
        didSet {
            
            if isActionOneSelected {
                self.actionOne.isSelected = true
                self.actionOne.setImage(self.actionImages.actionOneSelected, for: UIControlState.selected)
            }else {
                self.actionOne.isSelected = false
                self.actionOne.setImage(self.actionImages.actionOneUnSelected, for: UIControlState())
            }
        }
    }
    
    /// is ActionTwo selected
    var isActionTwoSelected : Bool = false {
        
        didSet {
            if isActionTwoSelected {
                self.actionTwo.isSelected = true
                self.actionTwo.setImage(self.actionImages.actionTwoSelected, for: UIControlState.selected)
            }else {
                self.actionTwo.isSelected = false
                self.actionTwo.setImage(self.actionImages.actionTwoUnSelected, for: UIControlState())
            }
        }
    }
    
    /// is ActionThree selected
    var isActionThreeSelected : Bool = false {
        
        didSet {
            if isActionThreeSelected {
                self.actionThree.isSelected = true
                self.actionThree.setImage(self.actionImages.actionThreeSelected, for: UIControlState.selected)
            }else {
                self.actionThree.isSelected = false
                self.actionThree.setImage(self.actionImages.actionThreeUnSelected, for: UIControlState())
            }
        }
    }
    
    
    /* Timer for update time*/
    fileprivate var timer: Timer!
    
    /* Controlling progress bar animation with isAnimating */
    fileprivate var isAnimating : Bool = false
    
    /* increasing duration in updateTime */
    fileprivate var duration : Double{
        didSet{
            redrawStrokeEnd()
            
            if let theDelegate = self.delegate {
                theDelegate.interactivePlayerViewDidChangedDuration(self, currentDuration: duration)
            }
            
        }
    }

    fileprivate var circleLayer: CAShapeLayer! = CAShapeLayer()

    /* Setting action buttons constraint width - height with buttonSizes */
    @IBInspectable var buttonSizes : CGFloat = 20.0 {
        
        didSet {
            self.actionOneButtonHeight.constant = buttonSizes
            self.actionOneButtonWidth.constant = buttonSizes
            self.actionTwoButtonHeight.constant = buttonSizes
            self.actionTwoButtonWidth.constant = buttonSizes
            self.actionThreeButtonHeight.constant = buttonSizes
            self.actionThreeButtonWidth.constant = buttonSizes
        }
    }
    
    /* 
     *
     * Set Images in storyBoard with IBInspectable variables
     *
     */
    @IBInspectable var coverImage: UIImage? {
        get {
            return coverImageView.image
        }
        set(coverImage) {
            coverImageView.image = coverImage
        }
    }
    
    @IBInspectable var actionOne_icon_selected: UIImage? {
        
        get {
            return actionImages.actionOneSelected
        }
        set(actionOne_icon_selected) {
            actionOne.setImage(actionOne_icon_selected, for: UIControlState.selected)
            actionImages.actionOneSelected = actionOne_icon_selected
        }
    }
    
    @IBInspectable var actionOne_icon_unselected: UIImage? {
        
        get {
            return actionImages.actionOneUnSelected
        }
        set(actionOne_icon_unselected) {
            actionOne.setImage(actionOne_icon_unselected, for: UIControlState())
            actionImages.actionOneUnSelected = actionOne_icon_unselected
        }
    }
    
    @IBInspectable var actionTwo_icon_selected: UIImage? {
        
        get {
            return actionImages.actionTwoSelected
        }
        set(actionTwo_icon_selected) {
            actionTwo.setImage(actionTwo_icon_selected, for: UIControlState.selected)
            actionImages.actionTwoSelected = actionTwo_icon_selected
        }
    }
    
    @IBInspectable var actionTwo_icon_unselected: UIImage? {
        
        get {
            return actionImages.actionTwoUnSelected
        }
        set(actionTwo_icon_unselected) {
            actionTwo.setImage(actionTwo_icon_unselected, for: UIControlState())
            actionImages.actionTwoUnSelected = actionTwo_icon_unselected
        }
    }
    
    @IBInspectable var actionThree_icon_selected: UIImage? {
        
        get {
            return actionImages.actionThreeSelected
        }
        set(actionThree_icon_selected) {
            actionThree.setImage(actionThree_icon_selected, for: UIControlState.selected)
            actionImages.actionThreeSelected = actionThree_icon_selected
        }
    }
    
    @IBInspectable var actionThree_icon_unselected: UIImage? {
        
        get {
            return actionImages.actionThreeUnSelected
        }
        set(actionThree_icon_unselected) {
            actionThree.setImage(actionThree_icon_unselected, for: UIControlState())
            actionImages.actionThreeUnSelected = actionThree_icon_unselected
        }
    }
    
    /*
     * Button images struct
     */
    
    struct ActionButtonImages {
        
        var actionOneSelected : UIImage?
        var actionOneUnSelected : UIImage?
        var actionTwoSelected : UIImage?
        var actionTwoUnSelected : UIImage?
        var actionThreeSelected : UIImage?
        var actionThreeUnSelected : UIImage?
        
    }
    
    override init(frame: CGRect) {
       
        self.duration = 0
        
        super.init(frame: frame)
        self.createUI()
        self.addPanGesture()

    }
    
    required init?(coder aDecoder: NSCoder) {
      
           self.duration = 0
        
        super.init(coder: aDecoder)
        self.createUI()
         self.addPanGesture()
       
    }
    
    @IBAction fileprivate func actionOneButtonTapped(_ sender: UIButton) {
        
        if sender.isSelected {
            sender.isSelected = false
        }else {
            sender.isSelected = true
        }
        
        self.isActionOneSelected = sender.isSelected
        
        if let delegate = self.delegate{
            delegate.actionOneButtonTapped(sender, isSelected : sender.isSelected)
        }
    }
    
    @IBAction fileprivate func actionTwoButtonTapped(_ sender: UIButton) {

        if sender.isSelected {
            sender.isSelected = false
        } else {
            sender.isSelected = true
        }

        self.isActionTwoSelected = sender.isSelected
        
        if let delegate = self.delegate{
            delegate.actionTwoButtonTapped(sender, isSelected : sender.isSelected)
        }
    }
    
    @IBAction fileprivate func actionThreeButtonTapped(_ sender: UIButton) {
        
        if sender.isSelected {
            sender.isSelected = false
        }else {
            sender.isSelected = true
        }
        
        self.isActionThreeSelected = sender.isSelected
        
        if let delegate = self.delegate{
            delegate.actionThreeButtonTapped(sender, isSelected : sender.isSelected)
        }
    }
    
    override func draw(_ rect: CGRect) {
        
        self.addCirle(self.bounds.width + 10, capRadius: 2.0, color: self.progressEmptyColor,strokeStart: 0.0,strokeEnd: 1.0)
        self.createProgressCircle()
        
    }
    
/**    override func animationDidStart(_ anim: CAAnimation) {

        circleLayer.strokeColor = self.progressFullColor.cgColor
        self.isAnimating = true
        self.duration = 0
    }
    
    override func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        self.isAnimating = false
        circleLayer.strokeColor = UIColor.clear.cgColor
        
        if(timer != nil) {
            timer.invalidate()
            timer = nil
        }
    }**/
    
    fileprivate func createUI() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        coverImageView.backgroundColor = UIColor.clear
        view.backgroundColor = UIColor.clear
        
        self.makeItRounded(view, newSize: view.bounds.width)
        self.backgroundColor = UIColor.clear
        
        addSubview(view)
    }
    
    fileprivate func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "InteractivePlayerView", bundle: bundle)
        
        // Assumes UIView is top level and only object in CustomView.xib file
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView

        return view
    }
    
    fileprivate func makeItRounded(_ view : UIView!, newSize : CGFloat!){
        let saveCenter : CGPoint = view.center
        let newFrame : CGRect = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: newSize, height: newSize)
        view.frame = newFrame
        view.layer.cornerRadius = newSize / 2.0
        view.clipsToBounds = true
        view.center = saveCenter
    }
    
    fileprivate func addCirle(_ arcRadius: CGFloat, capRadius: CGFloat, color: UIColor, strokeStart : CGFloat, strokeEnd : CGFloat) {

        let centerPoint = CGPoint(x: self.bounds.midX , y: self.bounds.midY)
        let startAngle = CGFloat(M_PI_2)
        let endAngle = CGFloat(M_PI * 2 + M_PI_2)
        
        let path = UIBezierPath(arcCenter:centerPoint, radius: frame.width/2+5, startAngle:startAngle, endAngle:endAngle, clockwise: true).cgPath
        
        let arc = CAShapeLayer()
        arc.lineWidth = 2
        arc.path = path
        arc.strokeStart = strokeStart
        arc.strokeEnd = strokeEnd
        arc.strokeColor = color.cgColor
        arc.fillColor = UIColor.clear.cgColor
        arc.shadowColor = UIColor.black.cgColor
        arc.shadowRadius = 0
        arc.shadowOpacity = 0
        arc.shadowOffset = CGSize.zero
        layer.addSublayer(arc)
        
    }
    
    
    fileprivate func createProgressCircle(){
        let centerPoint = CGPoint(x: self.bounds.midX , y: self.bounds.midY)
        let startAngle = CGFloat(M_PI_2)
        let endAngle = CGFloat(M_PI * 2 + M_PI_2)
        
        // Use UIBezierPath as an easy way to create the CGPath for the layer.
        // The path should be the entire circle.
        let circlePath = UIBezierPath(arcCenter:centerPoint, radius: frame.width/2+5, startAngle:startAngle, endAngle:endAngle, clockwise: true).cgPath
        
        // Setup the CAShapeLayer with the path, colors, and line width
        circleLayer = CAShapeLayer()
        circleLayer.path = circlePath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.shadowColor = UIColor.black.cgColor
        circleLayer.strokeColor = self.progressFullColor.cgColor
        circleLayer.lineWidth = 2.0;
        circleLayer.strokeStart = 0.0
        circleLayer.shadowRadius = 0
        circleLayer.shadowOpacity = 0
        circleLayer.shadowOffset = CGSize.zero
        
        // draw the colorful , nice progress circle
        circleLayer.strokeEnd = CGFloat(duration/progress)
        
        // Add the circleLayer to the view's layer's sublayers
        layer.addSublayer(circleLayer)
    }
    
    
    fileprivate func redrawStrokeEnd(){
        circleLayer.strokeEnd = CGFloat(duration/progress)
    }
    
    fileprivate func resetAnimationCircle(){
        stopTimer()
        duration = 0
        circleLayer.strokeEnd = 0
    }
    
    fileprivate func pauseLayer(_ layer : CALayer) {
        let pauseTime = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = 0.0
        layer.timeOffset = pauseTime
    }
    
    fileprivate func resumeLayer(_ layer : CALayer) {
        let pausedTime = layer.timeOffset
        layer.speed = 1.0
        layer.timeOffset = 0.0
        layer.beginTime = 0.0
        let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        layer.beginTime = timeSincePause
    }
    
    fileprivate func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(InteractivePlayerView.updateTime), userInfo: nil, repeats: true)

        if let theDelegate = self.delegate {
            theDelegate.interactivePlayerViewDidStartPlaying(self)
        }
    }
    
    fileprivate func stopTimer(){
       
        if(timer != nil) {
            timer.invalidate()
            timer = nil
            
            if let theDelegate = self.delegate {
                theDelegate.interactivePlayerViewDidStopPlaying(self)
            }
            
        }
        
    }
    
    func updateTime(){
        
        self.duration += 0.1
        let totalDuration = Int(self.duration)
        let min = totalDuration / 60
        let sec = totalDuration % 60
        
        timeLabel.text = NSString(format: "%i:%02i",min,sec ) as String
        
        if(self.duration >= self.progress)
        {
            stopTimer()
        }
        
    }
    
    /* Start timer and animation */
    func start(){
        self.startTimer()
    }
    
    /* Stop timer and animation */
    func stop(){
       self.stopTimer()
    }
    
    func restartWithProgress(duration : Double){
        progress = duration
        self.resetAnimationCircle()
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(InteractivePlayerView.start), userInfo: nil, repeats: false)
    }
    
}


// MARK: - Gestures
extension InteractivePlayerView{
    
    func addPanGesture(){
        let gesture:UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(InteractivePlayerView.handlePanGesture(_:)))
        gesture.maximumNumberOfTouches = 1
        self.addGestureRecognizer(gesture)
    }
    
    
    func handlePanGesture(_ gesture:UIPanGestureRecognizer){
        if(!self.panEnabled){
            return;
        }
        
        let translation:CGPoint = gesture.translation(in: self)
      
        
        let xDirection:CGFloat  = translation.x
        let yDirection:CGFloat =  -1 * translation.y
        
        let rate:CGFloat = yDirection+xDirection // rate of forward/backwards
        
        
        
        if(gesture.state == UIGestureRecognizerState.began){
            stopTimer()
        }
        else if(gesture.state == UIGestureRecognizerState.changed){
            duration += Double(rate/4)
            
            if(duration < 0 ){
                duration = 0
            }
            else if(duration >= progress){
                duration = progress
            }
        }
        else if(gesture.state == UIGestureRecognizerState.ended){
            startTimer()
        }
        
        
        gesture.setTranslation(CGPoint.zero, in: self)
    }
    
    
}



