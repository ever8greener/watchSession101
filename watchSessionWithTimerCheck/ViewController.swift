//
//  ViewController.swift
//  watchSessionWithTimerCheck
//
//  Created by artist on 4/30/16.
//  Copyright © 2016 artist. All rights reserved.
//


/*
 아래 체크필요:http://blog.mikeswanson.com/post/117807821714/watchkit-development-tips
 근데 iOS 8.2부터 지원...
 
 NSExtensionHostWillEnterForegroundNotification
 NSExtensionHostDidEnterBackgroundNotification
 NSExtensionHostWillResignActiveNotification
 NSExtensionHostDidBecomeActiveNotification
 
 */
import UIKit
import WatchConnectivity

class ViewController: UIViewController {
    private let session: WCSession? = WCSession.isSupported() ? WCSession.defaultSession() : nil
    
    let TIME_INCREMENT = 0.5
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var NSDateLabel: UILabel!
    var timer = NSTimer()
    var counter :Double = 0.0
    
    var mPlayer = Player()
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        configureWCSession()
        mPlayer.play()
        timer = NSTimer.scheduledTimerWithTimeInterval(TIME_INCREMENT, target:self, selector:#selector(updateCounter), userInfo: nil, repeats: true)
 
    }
    
    func updateCounter() {
        sendToWatch()

        currentTimeLabel.text = "\(mPlayer.currentTime)"
        
        NSDateLabel.text = "\(NSDate())"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func actionPlayerStop(sender: AnyObject) {
        mPlayer.stop()
        currentTimeLabel.text = "00:00"
    }
    
    @IBAction func actionPlayerPlay(sender: AnyObject) {
        mPlayer.play()
        
    }
}
extension ViewController: WCSessionDelegate {
    
    func sendToWatch(){
        
        
        let dateCreate =  NSDate() //currentTime 을 구하는 시점
        let dateAfter   = NSDate() //와치에 data 송신 직전
        
        let dateCreatedDouble = Double( dateCreate.timeIntervalSince1970)
        let dateDiff = Double( dateAfter.timeIntervalSinceDate(dateCreate))
        // 들어온날짜:2.02655792236328e-06  찰나의 순간에서 아주쬐끔 시간이 흐르네.
        // 사실 거의 차이는 없음  0에 가까움.
        
        
        var  applicationData = ["counterValueiPhone" : counter]
        applicationData["dateCreatedSince1970"] = dateCreatedDouble
        applicationData["dateDifference"] = dateDiff
        applicationData["currentTime"] = mPlayer.currentTime

        
        // The paired iPhone has to be connected via Bluetooth.
        if let session = session where session.reachable {
            session.sendMessage(applicationData,
                                replyHandler: { replyData in
                                    // handle reply from iPhone app here
                                    print(replyData)
                }, errorHandler: { error in
                    // catch any errors here
                    print(error)
            })
        } else {
            // when the iPhone is not connected via Bluetooth
        }

    }
    private func configureWCSession() {
        session?.delegate = self;
        session?.activateSession()
    }
}

class Player  {
    
    let TIME_INCREMENT = 0.1
    var timer = NSTimer()

    var currentTime = 0.0
    
    init(){
        currentTime = 8.0
        print("초기화됨")
    }
    func play(){
        
        if timer.valid == false {
        timer = NSTimer.scheduledTimerWithTimeInterval(TIME_INCREMENT, target:self, selector:#selector(updateCounter), userInfo: nil, repeats: true)
        }

    }
    func stop(){
        self.timer.invalidate()
        currentTime = 0.0
    }
    
    @objc func updateCounter() {
         currentTime += TIME_INCREMENT
    }

}

