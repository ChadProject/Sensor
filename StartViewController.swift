//
//  StartViewController.swift
//  Sensor
//
//  Created by Chadwick Zhao on 9/11/2016.
//  Copyright © 2016 youbing.song. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

    var timer = NSTimer()
    @IBOutlet weak var startBtn: UIButton!
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        UIApplication.sharedApplication().statusBarStyle = .LightContent

        // animation for advicing the user that this button is clickable
        delay(1.0){
            self.startBtn.shake()
        }

        // Do any additional setup after loading the view.
        timer = NSTimer.scheduledTimerWithTimeInterval(2.5, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        
    }
    
    
    func timerAction(){
        self.startBtn.shake() // shake()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func toPlayPage(sender: AnyObject) {
        performSegueWithIdentifier("toHome", sender: self)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }

}

extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 0.7
        animation.values = [20.0, -20.0, 20.0, -20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, -3.0, 0.0 ]
        layer.addAnimation(animation, forKey: "shake")
    }
}
