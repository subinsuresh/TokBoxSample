//
//  SubscibeViewController.swift
//  Publisher
//
//  Created by QBurst on 23/04/18.
//  Copyright © 2018 QBurst. All rights reserved.
//

import UIKit
import  OpenTok

class SubscibeViewController: UIViewController, OTSessionDelegate, OTSubscriberDelegate {

    let kApiKey = ""
    // Replace with your generated session ID
    let kSessionId = ""
    // Replace with your generated token
    let kToken = ""
    
    var session: OTSession? = nil
    var subscriber: OTSubscriber?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        session = OTSession(apiKey: kApiKey, sessionId: kSessionId, delegate: self)!
        self.doConnect()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func doConnect() {
        var error: OTError?
        defer {
            processError(error)
        }
        
        session?.connect(withToken: kToken, error: &error)
    }
    
    fileprivate func doSubscribe(_ stream: OTStream) {
        var error: OTError?
        defer {
            processError(error)
        }
        subscriber = OTSubscriber(stream: stream, delegate: self)
        session?.subscribe(subscriber!, error: &error)
    }
    
    func setTitle(title: String){
        DispatchQueue.main.async {
            self.title = title
        }
        
    }

    
    fileprivate func cleanupSubscriber() {
        subscriber?.view?.removeFromSuperview()
        subscriber = nil
    }
    
    fileprivate func processError(_ error: OTError?) {
        if let err = error {
            DispatchQueue.main.async {
                let controller = UIAlertController(title: "Error", message: err.localizedDescription, preferredStyle: .alert)
                controller.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(controller, animated: true, completion: nil)
            }
        }
    }

    func sessionDidConnect(_ session: OTSession) {
        print("Session connected")
        setTitle(title: "Session connected")
    }
    
    func sessionDidDisconnect(_ session: OTSession) {
        print("Session disconnected")
        setTitle(title: "Session disconnected")
    }
    
    func session(_ session: OTSession, streamCreated stream: OTStream) {
        print("Session streamCreated: \(stream.streamId)")
        setTitle(title: "Session streamCreated: \(stream.streamId)")
        if subscriber == nil {
            doSubscribe(stream)
        }
    }
    
    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        print("Session streamDestroyed: \(stream.streamId)")
        setTitle(title: "Session streamDestroyed: \(stream.streamId)")
        if let subStream = subscriber?.stream, subStream.streamId == stream.streamId {
            cleanupSubscriber()
        }
    }
    
    func session(_ session: OTSession, didFailWithError error: OTError) {
        print("session Failed to connect: \(error.localizedDescription)")
        setTitle(title: "session Failed to connect: \(error.localizedDescription)")
    }
    
    
    func subscriberDidConnect(toStream subscriberKit: OTSubscriberKit) {
        setTitle(title: "subscriberDidConnect")
        if let subsView = subscriber?.view {
            subsView.frame = self.view.frame
            view.addSubview(subsView)
        }
    }
    
    func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
        setTitle(title: "Subscriber failed: \(error.localizedDescription)")
        print("Subscriber failed: \(error.localizedDescription)")
    }
    
    func subscriberVideoEnabled(_ subscriber: OTSubscriberKit, reason: OTSubscriberVideoEventReason) {
        setTitle(title: "subscriberVideoEnabled")
    }
    
    func subscriberVideoDisabled(_ subscriber: OTSubscriberKit, reason: OTSubscriberVideoEventReason) {
        setTitle(title: "subscriberVideoDisabled")
    }
    
    func subscriberDidDisconnect(fromStream subscriber: OTSubscriberKit) {
        setTitle(title: "subscriberDidDisconnect")
    }
    
    func subscriberDidReconnect(toStream subscriber: OTSubscriberKit) {
        setTitle(title: "subscriberDidReconnect")
    }

}
