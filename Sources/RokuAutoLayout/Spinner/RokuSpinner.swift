//
//  File.swift
//  
//
//  Created by Powersel on 21.06.2022.
//

import UIKit

public protocol RokuSpinnerDelegate: AnyObject {
    func timerElapsed()
}

final public class RokuSpinner: UIView {
    weak var delegate: RokuSpinnerDelegate?
    
    weak var spinnerView: UIImageView?
    var displayLink: CADisplayLink?
    var theta: Float = 0
    var counter: Int = 0
    var counterTimer: Timer?
    var spinnerCounter: UILabel = UILabel()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override convenience init(frame: CGRect) {
        self.init(frame: frame, counter: -1)
    }
    
    public init(frame: CGRect, counter: Int) {
        super.init(frame: frame)
        self.counter = counter
        self.createView(useLargeImage: counter > 0)
    }
    
    public init(frame: CGRect, counter: Int, useLargeImage: Bool) {
        super.init(frame: frame)
        self.counter = counter
        self.createView(useLargeImage: useLargeImage)
    }
    
    public init(frame: CGRect, counter: Int, useLargeImage: Bool, spinnerColor: UIColor?) {
        super.init(frame: frame)
        self.counter = counter
        self.createView(useLargeImage: useLargeImage, spinnerColor: spinnerColor)
    }
    
    public init(frame: CGRect, counter: Int, image: UIImage) {
        super.init(frame: frame)
        self.counter = counter
        let size = CGFloat.maximum(image.size.width, image.size.height)
        self.createView(image: image, size: size)
    }

    public static func createMaskedImage(with image: UIImage, fillColor: UIColor) -> UIImage {
//        // create an image context based on that
//        let size = image.size
//
//
//        // get context
//        var context: CGContext = UIGraphicsGetCurrentContext() ?? nil
//        CGContextSaveGState(context)
        return UIImage()
    }
    
    deinit {
        endTimer()
        endSpin()
    }
    
    public func startSpin() {
        if displayLink == nil {
            displayLink = CADisplayLink.init(target: self, selector: #selector(displayUpdate))
            displayLink?.add(to: .main, forMode: .common)
        }
    }
    
    func endSpin() {
        if displayLink != nil {
            displayLink?.invalidate()
            displayLink = nil
        }
    }
}

private extension RokuSpinner {
    func createView(useLargeImage: Bool) {
        
    }
    
    func createView(useLargeImage: Bool, spinnerColor: UIColor?) {
        let size: CGFloat = useLargeImage ? 160.0 : 32.0
        let imageName = useLargeImage ? "ActivitySpinnerLarge" : "ActivitySpinnerSmall"
        
        let spinnerImage = UIImage(named: imageName)
        let image = spinnerColor == nil ? spinnerImage : RokuSpinner.createMaskedImage(with: spinnerImage!, fillColor: spinnerColor!)
        createView(image: image!, size: size)
    }
    
    func createView(image: UIImage, size: CGFloat) {
        _ = RokuAutoLayout.setWidthOf(view: self, width: size)
        _ = RokuAutoLayout.setHeightOf(view: self, height: size)
        
        let spinnerRect = CGRect(x: 0, y: 0, width: size, height: size)
        let spinnerView = UIImageView(frame: spinnerRect)
        spinnerView.image = image
        addSubview(spinnerView)
        self.spinnerView = spinnerView
        startSpin()
        
        // create label for counter if nec
        if counter > 0 {
            let spinnerCounterLabel = UILabel(frame: spinnerView.frame)
            self.spinnerCounter = spinnerCounterLabel
            addSubview(spinnerCounterLabel)
            spinnerCounterLabel.textColor = .white
            spinnerCounterLabel.font = UIFont(name: "HelveticaNeue", size: 22.0)
            setCounterText()
            spinnerCounterLabel.translatesAutoresizingMaskIntoConstraints = false
            _ = RokuAutoLayout.centerVertically(view: spinnerCounterLabel, in: self)
            _ = RokuAutoLayout.centerHorizontally(view: spinnerCounterLabel, in: self)
            counterTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(counterTick), userInfo: nil, repeats: true)
        }
    }
    
    func setCounterText() {
        spinnerCounter.text = String(format: "%d", counter)
    }
    
    @objc func counterTick() {
        counter = counter - 1
        if counter < 0 {
            if delegate != nil {
                delegate?.timerElapsed()
            }
            endTimer()
            return
        }
        setCounterText()
    }
    
    //MARK: - Rotations
    
    @objc func displayUpdate() {
        if superview != nil {
            theta = theta + 6.0
            let angle = theta * 0.0174533
            let transform = CGAffineTransform(rotationAngle: CGFloat(angle));
            spinnerView?.transform = transform
        } else {
            endTimer()
            endSpin()
        }
    }
    
    func endTimer() {
        if counterTimer != nil {
            counterTimer?.invalidate()
            counterTimer = nil
        }
    }
}
