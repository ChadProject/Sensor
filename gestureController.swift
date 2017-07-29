//
//  gestureController.swift
//  Assignment2
//
//  Created by Kaiwei Lin on 31/10/2016.
//  Copyright © 2016 Kaiwei Lin. All rights reserved.
//

import UIKit

class gestureController: UIViewController {
    struct Position {
        var Y : Double = 0.0
    }
    var poslist:Array<Position> = []
    var p:Position = Position()
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("start...")
        let posurl = NSURL(string: "http://118.139.12.106:8800/gestureYPosition")!
        let urlRequest = NSURLRequest(URL: posurl)
        let session = NSURLSession.sharedSession()
        //var resultText:String?
        
        //In order to synchronously wait until the data task has finished and then fetched data, we need to use a semaphore. Here we first create a semaphore:
        let semaphore = dispatch_semaphore_create(0)
        
        //Use completion handler for asynchronous tasks
        let task = session.dataTaskWithRequest(urlRequest) {
            (data, response, error) in
            //resultText = String(data: data!, encoding: NSUTF8StringEncoding)
            //print(resultText)
            do{
                if data != nil{
                    
                    // Convert JSON string to object array
                    let anyObj: AnyObject? = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                    
                    // Retrieve every json object in array
                    for json in anyObj as! Array<AnyObject>{
                        
                        // Retrieve every json object in array
                        self.p.Y = (json["position"] as AnyObject? as? Double)!
                        
                        // Append meter object to meterlist
                        self.poslist.append(self.p)
                    }
                }else{
                    print("sensor error")
                    //Alert.show("SENSOR ERROR", message: "Cannot get data from sensor!", vc: self)
                }
                //Increments the semaphore (send a semaphore signal)
                dispatch_semaphore_signal(semaphore)
                
            } catch let jsonError as NSError{
                // Catch JSON parser error
                print("JSON ERROR : \(jsonError.localizedDescription)")
                //Alert.show("JSON ERROR", message: "\(jsonError.localizedDescription)", vc: self)
            }
            
        }
        
        //resume the task
        task.resume()
        
        //Decrements the semaphore (wait for a semaphore signal).The semaphore will force the calling thread to stop and wait until it is signaled upon completion of the data task.
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        print("Finish..")
        for item in self.poslist{
            print(item.Y)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
