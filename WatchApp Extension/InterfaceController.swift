//
//  InterfaceController.swift
//  WatchApp Extension
//
//  Created by Eddie Kwon on 4/30/16.
//  Copyright © 2016 artist. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class InterfaceController: WKInterfaceController {

    private let session: WCSession? = WCSession.isSupported() ? WCSession.defaultSession() : nil
    
    let TIME_INCREMENT = 0.3

    var timer = NSTimer()
    var counter :Int = 0
    var currentTime:Double = 0

    @IBOutlet var currentTimeLabel: WKInterfaceLabel!
    @IBOutlet var currentTimeLabelMyself: WKInterfaceLabel!
    @IBOutlet var NSDateLabel: WKInterfaceLabel!
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
    }

    override func willActivate() {
        super.willActivate()
        
        configureWCSession()
        timer = NSTimer.scheduledTimerWithTimeInterval(TIME_INCREMENT, target:self, selector:#selector(updateCounter), userInfo: nil, repeats: true)
    }
    
    func updateCounter() {
        currentTimeLabelMyself.setText(  String(counter ) )
        counter += 1
         NSDateLabel.setText( "\(NSDate())" )
    }
 
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    
}

extension InterfaceController: WCSessionDelegate {
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        
        //Use this to update the UI instantaneously (otherwise, takes a little while)
        dispatch_async(dispatch_get_main_queue()) {
            if let  originalDate  = message["dateCreatedSince1970"] as? Double,
                     originalCurrentTime = message["currentTime"] as? Double
            {
                self.currentTime = self.calculateCurrentTime(originalDate, iOSCurrentTime: originalCurrentTime)
                self.currentTimeLabel.setText (String(self.currentTime))

                print("들어온날짜1970기준:\(originalDate) 시간:\(originalCurrentTime)")
            }else{
                print("파싱오류인듯.")
            }
        }
    }
    private func configureWCSession() {
        session?.delegate = self;
        session?.activateSession()
    }
    
    //Param:  iOSApp의 당시시각(NSDateInterval포맷), iOSApp의 당시 currentTime
    //Return: 현재 currentTime
    func calculateCurrentTime(dateOrgAs1970:Double , iOSCurrentTime:Double) -> Double {
        let now =  NSDate().timeIntervalSince1970 //현재시각 1970포맷
        let dateDifferenceBetweenWatchAndiOS = Double( now - dateOrgAs1970 )// 현재시각 - iOS당시시각
        return dateDifferenceBetweenWatchAndiOS + iOSCurrentTime
    }
    
}