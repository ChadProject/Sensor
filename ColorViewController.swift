//
//  ColorViewController.swift
//  Sensor

//

import UIKit
import CoreData

// iOS Apps: Using Nuance SpeechKit 2 with Swift 2
// https://www.youtube.com/watch?v=4DHJ6YeLOWI
import SpeechKit


//Swifty.json makes it easy to deal with json data in Swift.
//https://github.com/Swiftyjson/Swiftyjson
import SwiftyJSON
import AVFoundation

//dectect color and show them on the list
class ColorViewController: UIViewController, SKTransactionDelegate {
   
    @IBOutlet weak var voiceRegBtn: UIButton!
    @IBOutlet weak var resultLbl: UILabel!
    @IBOutlet weak var wave: Wave!
    @IBOutlet weak var playBtn: UIImageView!
    @IBOutlet weak var saveBtn: UIImageView!
    @IBOutlet weak var recordBtn: UIImageView!
    var managedObjectContext: NSManagedObjectContext!
    var m: Music!
    
    @IBOutlet weak var infoBtn: UILabel!
    
    @IBOutlet var SelectRow: UISegmentedControl!
    var red: Float = 0.0
    var blue: Float = 0.0
    var green: Float = 0.0
    var countdown = 0
    var myTimer: NSTimer? = nil
    var n:Int = 25
    struct Position {
    var Y : Double = 0.0
    }
    var poslist:Array<Position> = []
    var newPoslist:Array<Double> = []
    var p:Position = Position()
    
    var BaseURL:String = ""

    var rowNumber:Int?
    var hightOfwave:CGFloat?
    

    
    //============================================================
    //PLAY MUSIC LOGICS
    //THREE FUNCTIONS
    //1. recordMusic()     >> START TO RECORD         eg: recordMusic()
    //2. playMusic()       >> PLAY RECORDED MUSIC     eg: playMusic()
    //3. modifyPlaySpeed   >> CHANGE THE PACE         eg: modifyPlaySpeed(0.5)
    //
    //TODO:  UI DISPLAY ERRORS  !!!#$%@#^!!!
    //============================================================
    
    var json:JSON?
    var jsons1:JSON?
    var jsons2:JSON?
    
    var musicTimer:NSTimer?
    var levelIndexPlayed:Int = 1
    var speed:Double = 0.5
    var maxRGB:Int = 1
    var maxCategory = "red"
    var backgroundMusicPlayer = AVAudioPlayer()
    
    //PRIVATE METHOD
    func playBackgroundMusic(filename: String) {
        let url = NSBundle.mainBundle().URLForResource(filename, withExtension: nil)
        guard let newURL = url else {
            print("Could not find file: \(filename)")
            return
        }
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOfURL: newURL)
            backgroundMusicPlayer.numberOfLoops = 0
            backgroundMusicPlayer.prepareToPlay()
            backgroundMusicPlayer.play()
        } catch let error as NSError {
            print(error.description)
            Alert.show("PLAY ERROR", message: "\(error.description)", vc: self)
        }
    }
    //PRIVATE METHOD
    func play() {
        // Code here
      
        var level = Int(ceilf(self.json![self.levelIndexPlayed-1][self.maxCategory].float!/255/64/50))
        
        hightOfwave = CGFloat(level)
        
        if(level > 4){ level = 5 }
        playBackgroundMusic(String(self.maxRGB) + String(level) + ".wav")
        if(self.levelIndexPlayed == self.json?.count){
            self.musicTimer!.invalidate()
            infoBtn.text = "Playing end."
        }
        self.levelIndexPlayed++
    }
    
    // PUBLIC METHOD
    // record method
    func recordMusic(){
        infoBtn.text = "Recording Music"
        self.json = nil
        getjsonfroms1(10)
        getjsonfroms2(10)
        getGestureData()
    }
    
    // merge json from two servers.
    func mergeMusic(){
        if(jsons1 == nil || jsons2 == nil){
            self.infoBtn.text = "Sounds something wrong with the data..."
            return
        }
        
        self.json = JSON(jsons1!.arrayObject! + jsons2!.arrayObject!)
        
    }
    
    
    // PUBLIC METHOD
    // playMusic Method
    func playMusic(){
        //stop playing
        if((self.musicTimer) != nil){
            self.musicTimer!.invalidate()
        }
        if(self.json != nil){
            self.infoBtn.text = "No music is recorded, plz try again."
            return
        }
        
        self.infoBtn.text = "Playing music..."
      
       // wave.waveWidth = hightOfwave!
        wave.direction = .Right
       // wave.fps = speed
        //check json
        if(self.json?.count == 0 ){
            print("Network Error")  ////TODO  UI  DISPLAY
            //Alert.show("NETWORK ERROR", message: "Network connection failed!", vc: self)
            self.infoBtn.text = "Network connection failed!"
            return
        }
        mergeMusic()
        
        //get max category
        var maxNum = max(max(self.json![0]["red"],self.json![0]["green"]),self.json![0]["blue"])
        if(maxNum == self.json![0]["green"]){
            maxRGB = 2
            maxCategory = "green"
        }else if(maxNum == self.json![0]["blue"]){
            maxRGB = 3
            maxCategory = "blue"
        }
        if (newPoslist.count >= 2){
            
        var nvalue = newPoslist[newPoslist.count-1]
        var pvalue = newPoslist[0]
        
        
        speed = 0.5
       
        // implementation for speed of music according to palm position for leap motion.
        print (pvalue,nvalue)
            // if position of palm rises decrease the interval between two tones.
        if (nvalue > pvalue && speed <= 1 && speed >= 0.1){
            speed = speed-0.2
            print("speed increase")
        }
            // if position of palm falls increase the gap between tones
        else if (nvalue < pvalue && speed <= 1 && speed >= 0.1){
            speed = speed+0.2
            print("speed decrease")
        }
        else{
            speed = 0.5
        }
        
        
        //Declare the timer
        self.musicTimer = NSTimer.scheduledTimerWithTimeInterval(speed, target:
            self, selector: "play", userInfo: nil, repeats: true)
        self.levelIndexPlayed = 1
        
    }
    }
    
    //PUBLIC METHOD
    // speed should be ranging from 0.1 to 1
    func modifyPlaySpeed(newSpeed: Double){
        self.speed = newSpeed
    }
    
    //============================================================
    //END PLAY MUSIC LOGICS
    //============================================================

    override func viewDidLoad() {
        super.viewDidLoad()
        // get sensor data from the RASPI
      //  getjson(n)
        
       
        
        wave.direction = .Stop
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ColorViewController.recordMusic))
        recordBtn.addGestureRecognizer(tap)
        recordBtn.userInteractionEnabled = true
        
        //
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(ColorViewController.playMusic))
        playBtn.addGestureRecognizer(tap1)
        playBtn.userInteractionEnabled = true

        //
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(ColorViewController.savePlayedMusic))
        saveBtn.addGestureRecognizer(tap2)
        saveBtn.userInteractionEnabled = true
        
        // Do any additional setup after loading the view.
        
    }
    

    // save music to database.
    func savePlayedMusic(){
       
        let alertController = UIAlertController(title: "Save recorded music?", message: "Please input your music name:", preferredStyle: .Alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .Default) { (_) in
            if let field = alertController.textFields![0] as? UITextField {
                // store your data
                NSUserDefaults.standardUserDefaults().setObject(field.text, forKey: "Name")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                print(field.text!)
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                if  self.json?.count != nil {
                    self.managedObjectContext = appDelegate.managedObjectContext
                    self.m = Music.init(entity: NSEntityDescription.entityForName("Music", inManagedObjectContext: self.managedObjectContext )!,insertIntoManagedObjectContext: self.managedObjectContext)
                    self.m!.setValue(String(field.text!), forKey: "name")
                    self.m!.setValue(String(self.speed), forKey: "speed")
                    self.m!.setValue(String(self.json!), forKey: "record")
                }else{
                    //Alert.show("SENSOR ERROR", message: "Cannot get data from sensor!", vc: self)
                    //print("no json")
                    self.infoBtn.text = "Cannot get data from sensor!"
                }
                
            } else {
                // user did not fill field
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Name"
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        musicTimer?.invalidate()
        myTimer?.invalidate()
        //UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        
    }
  
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
       UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        // set a time to retrive data repeatedly
        myTimer = NSTimer.scheduledTimerWithTimeInterval( 0.01, target: self, selector: "countDownTick", userInfo: nil, repeats: true)

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //Alert.show("USER INSTRUCTION", message: "", vc: self)
        
        
        
    }
    
    // triggle timer method
    func countDownTick(){
        getjsonfroms1(10)
        getjsonfroms2(10)
    }
    
    // get json from server 1 for RGB values
    func getjsonfroms1(n:Int?){
        // URL for retrieve data
        BaseURL = "http://118.139.12.106:8080/?n=" + (n?.description)!
        let url = NSURL(string: BaseURL)
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!)
        {
            (mydata, respinse, error) in
            
            // render data
            if error == nil {
                self.jsons1 = JSON(data: mydata!)
                
                
            } else {
                //Alert.show("SENSOR ERROR", message: "Cannot get color data from sensor1!", vc: self)
                self.infoBtn.text = "Cannot get color data from sensor1!"
            }
            
        }
        task.resume()
        
    }
    
    //get json from server 2 for RGB values
    func getjsonfroms2(n:Int?){
        // URL for retrieve data
        BaseURL = "http://118.139.29.216:8080/?n=" + (n?.description)!
        let url = NSURL(string: BaseURL)
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!)
        {
            (mydata, respinse, error) in
            
            // render data
            if error == nil {
                self.jsons2 = JSON(data: mydata!)
                
                
            } else {
                //Alert.show("SENSOR ERROR", message: "Cannot get color data from sensor2!", vc: self)
                 self.infoBtn.text = "Cannot get color data from sensor2!"
            }
            
        }
        task.resume()
        
    }
    
    // get sensor data from leap motion
    
    func getGestureData(){
        let posurl = NSURL(string: "http://118.139.12.106:8080/gestureYPosition")!
        let urlRequest = NSURLRequest(URL: posurl)
        let session = NSURLSession.sharedSession()
        
        //In order to synchronously wait until the data task has finished and then fetched data, we need to use a semaphore. Here we first create a semaphore:
        
        let semaphore = dispatch_semaphore_create(0)
        
        //Use completion handler for asynchronous tasks
        let task = session.dataTaskWithRequest(urlRequest) {
            (data, response, error) in
            
            
            do{
                if data != nil{
                    
                    
                    
                    // Convert JSON string to object array
                    let anyObj: AnyObject? = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                    
                    // Retrieve every json object in array
                    for json in anyObj as! Array<AnyObject>{
                        if(json["position"] != nil){
                            
                            // Retrieve every json object in array
                            self.p.Y = (json["position"] as AnyObject? as? Double )!
                            
                            // Append meter object to meterlist
                            self.poslist.append(self.p)
                        }
                        else{
                            //Alert.show("JSON ERROR", message: "Convert to json data failed!", vc: self)
                             self.infoBtn.text = "Convert to json data failed!"
                        }
                    }
                }else{
                    print("sensor error")
                    //Alert.show("SENSOR ERROR", message: "Cannot get data from sensor!", vc: self)
                    self.infoBtn.text = "Cannot get data from sensor!"
                }
                
                //Increments the semaphore (send a semaphore signal)
                dispatch_semaphore_signal(semaphore)
                
                
            } catch let jsonError as NSError{
                // Catch JSON parser error
                //print("JSON ERROR : \(jsonError.localizedDescription)")
                //Alert.show("JSON ERROR", message: "\(jsonError.localizedDescription)", vc: self)
                self.infoBtn.text = "\(jsonError.localizedDescription)"
            }
            
        }
        
        //resume the task
        task.resume()
        
        //Decrements the semaphore (wait for a semaphore signal).The semaphore will force the calling thread to stop and wait until it is signaled upon completion of the data task.
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        
        print("Finish..")
        for item in self.poslist{
            newPoslist.append(item.Y)
            print(item.Y)
        }

    }
    //============================================================
    //VOICE RECOGNIZATION (Text to Speech)
    //============================================================
    
    @IBAction func voiceRegBtn(sender: UIButton) {
        voiceRegBtn.setTitle("Listening", forState: .Normal)
        
        // Set up session with URL, App key, recognization type
        let session = SKSession(URL: NSURL(string: "nmsps://NMDPTRIAL_kaiweilin927_gmail_com20161112000512@sslsandbox-nmdp.nuancemobility.net:443"), appToken: "3e68f2a03967c9da84e99f867d560d1c6d39972f42723c8a1a3e130e7cb634ba1e275a578e2331120dd0998a26a6a694df3dc322afffacca3dbfd8b9750c7393")
        session.recognizeWithType(SKTransactionSpeechTypeDictation,
                                  detection: .Long,
                                  language: "eng-USA",
                                  delegate: self)
    }
    
    // MARK: - SKTransactionDelegate
    func transaction(transaction: SKTransaction!, didReceiveRecognition recognition: SKRecognition!) {
        //resultLabel.text = recognition.text
        // If the recognition equals "start to record", the invoke the recordMusic(),else if the recognition equals "stop and play", the invoke the playMusic()
        resultLbl.text = recognition.text
        if (resultLbl.text!.lowercaseString.containsString("record")){
            recordMusic()
            
        }else if(resultLbl.text!.lowercaseString.containsString("play")){
            playMusic()
        }else{
            self.infoBtn.text = "Wrong command"
        }
        voiceRegBtn.setTitle("Listen", forState: .Normal)
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

