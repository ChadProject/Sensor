//
//  Alert.swift
//  Assignment2
//
//  Created by Kaiwei Lin on 11/10/2016.
//  Copyright © 2016 Kaiwei Lin. All rights reserved.
//

import UIKit

class Alert: NSObject {
    
    static func show(title:String, message:String, vc: UIViewController)
    {
        //create alert controller
        let alertCT = UIAlertController(title: title, message: message,preferredStyle: UIAlertControllerStyle.Alert)
        
        //create Alert Action
        let okAction = UIAlertAction(title:"Ok",style: UIAlertActionStyle.Default){
            (alert:UIAlertAction) -> Void in alertCT.dismissViewControllerAnimated(true, completion:nil)
        }
        
        //add alert action to controller
        alertCT.addAction(okAction)
        
        //display alert controller
        vc.presentViewController(alertCT,animated: true, completion: nil)
        
        
    }
}
