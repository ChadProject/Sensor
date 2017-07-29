//
//  Wave.swift
//  Sensor
//
//  Created by Chadwick Zhao on 9/11/2016.
//  Copyright © 2016 youbing.song. All rights reserved.
//
import UIKit

//This class is implemented from https://github.com/zhangxigithub/Wave 
//

public enum WaveDirection
{
    case Left
    case Stop
    case Right
}

public class Wave : UIView
{
    public var fps:        Double  = 30        { didSet{ setup(true) } }
    public var waveWidth:  CGFloat = 100.0     { didSet{ setup()     } }
    public var waveHeight: CGFloat = 30.0      { didSet{ setup()     } }
    public var variance:   Int     = 50        { didSet{ setup(true) } }
    public var stokeColor: UIColor = UIColor(red: 250.0/255.0, green: 69.0/255.0, blue: 89.0/255.0, alpha: 0.6)
    public var fillColor:  UIColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.2)
    
    public var direction:WaveDirection = .Right
        {
        didSet{
            switch direction
            {
            case .Left:  start()
            case .Stop:  timer.invalidate()
            case .Right: start()
            }
        }
    }
    
    private var timer:NSTimer!
    private var variances = [CGFloat]()
    private var step:CGFloat = 0
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor =  UIColor.whiteColor()
        setup(true)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup(true)
    }
    
    func start()
    {
        timer?.invalidate()
        timer  = NSTimer.scheduledTimerWithTimeInterval(1.0/fps, target: self, selector: #selector(self.f), userInfo: nil, repeats: true)
    }
    
    func setup(restartTimer:Bool = false)
    {
        if restartTimer
        {
            variances.removeAll()
            start()
        }
        
        let count = Int(self.frame.size.width / waveWidth) + 3
        for _ in 0 ..< count
        {
            variances.append(CGFloat(arc4random_uniform(UInt32(variance))))
        }
        variances.removeRange(count ..< variances.count)
        self.setNeedsDisplay()
    }
    func f()
    {
        self.setNeedsDisplay()
    }
    
    override public func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let context = UIGraphicsGetCurrentContext()
        stokeColor.setStroke()
        fillColor.setFill()
        
        //left-top
        let LT = CGPointMake(step-waveWidth, self.frame.size.height/2)
        //right-bottom
        let RB = CGPointMake(step + waveWidth*CGFloat(variances.count), self.frame.size.height)
        
        CGContextBeginPath(context);
        CGContextMoveToPoint(context,LT.x,LT.y);
        
        for (x,height) in variances.enumerate()
        {
            let p = CGPointMake(step + waveWidth*CGFloat(x), self.frame.size.height/2)
            let cp1 = CGPointMake(p.x - (3.0/4.0)*waveWidth ,p.y + (waveHeight + CGFloat(variance/2) - height))
            let cp2 = CGPointMake(p.x - (1.0/4.0)*waveWidth, p.y - (waveHeight + CGFloat(variance/2) - height))
            
            CGContextAddCurveToPoint(context, cp1.x, cp1.y, cp2.x, cp2.y, p.x, p.y);
        }
        
        CGContextAddLineToPoint(context, RB.x, RB.y);
        CGContextAddLineToPoint(context, LT.x, RB.y);
        CGContextAddLineToPoint(context, LT.x, LT.y);
        
        switch direction {
        case .Left:  step -= 1
        case .Stop:  break
        case .Right: step += 1
        }
        
        if abs(step) >= waveWidth
        {
            switch direction {
            case .Left:
                step = 0
                variances.append(CGFloat(arc4random_uniform(UInt32(variance))))
                variances.removeFirst()
            case .Right, .Stop:
                step = 0
                variances.insert(CGFloat(arc4random_uniform(UInt32(variance))), atIndex: 0)
                variances.removeLast()
            }
        }
        CGContextDrawPath(context,.FillStroke)
    }
}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


