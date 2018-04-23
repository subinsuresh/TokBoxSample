//
//  PublishViewController.swift
//  Publisher
//
//  Created by QBurst on 23/04/18.
//  Copyright © 2018 QBurst. All rights reserved.
//

import UIKit
import OpenTok

class PublishViewController: UIViewController, OTPublisherDelegate, OTSessionDelegate {

    // *** Fill the following variables using your own Project info  ***
    // ***            https://tokbox.com/account/#/                  ***
    // Replace with your OpenTok API key
    let kApiKey = ""
    // Replace with your generated session ID
    let kSessionId = ""
    // Replace with your generated token
    let kToken = ""
    
    var session: OTSession? = nil
    var shouldPublishVideo = false
    let reachability = Reachability()

    
    @IBOutlet weak var startStopButton : UIButton!
    
    lazy var publisher: OTPublisher = {
        let settings = OTPublisherSettings()
        settings.name = UIDevice.current.name
        settings.cameraResolution = .high
        settings.cameraFrameRate = .rate30FPS
        settings.audioBitrate = 64000
        return OTPublisher(delegate: self, settings: settings)!
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        publisher.cameraPosition = .back
        publisher.videoType = .screen
        session = OTSession(apiKey: kApiKey, sessionId: kSessionId, delegate: self)!
        self.startMonitoring()
        if let pubView = publisher.view {
            pubView.frame = self.view.frame
            view.addSubview(pubView)
            self.view.bringSubview(toFront: self.startStopButton)
        }
        // Do any additional setup after loading the view.
    }
    
    func startMonitoring() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.reachabilityChanged),
                                               name: ReachabilityChangedNotification,
                                               object: reachability)
        do{
            try reachability?.startNotifier()
        } catch {
            print("Could not start reachability notifier")
        }
    }
    
    func reachabilityChanged(_ notification : NSNotification) {
        
        let reachability = notification.object as! Reachability
        let status = reachability.isReachable
        if shouldPublishVideo {
            if status {
                if !self.haveActiveSession() {
                    doConnect()
                }
                
            }else{
                
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.stopMonitoring()
    }
    
    func setTitle(title: String){
        DispatchQueue.main.async {
            self.title = title
        }

    }
    
    func stopMonitoring(){
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self,
                                                  name: ReachabilityChangedNotification,
                                                  object: reachability)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     * Asynchronously begins the session connect process. Some time later, we will
     * expect a delegate method to call us back with the results of this action.
     */
    fileprivate func doConnect() {
        var error: OTError?
        defer {
            processError(error)
        }
        
        session?.connect(withToken: kToken, error: &error)
    }
    
    
    /**
     * Sets up an instance of OTPublisher to use with this session. OTPubilsher
     * binds to the device camera and microphone, and will provide A/V streams
     * to the OpenTok session.
     */
    
    func haveActiveSession() -> Bool {
        if session?.sessionConnectionStatus == .notConnected || session?.sessionConnectionStatus == .failed {
            return false
        }else{
            return true
        }
    }
    
    fileprivate func doPublish() {
        
        if !haveActiveSession() {
            self.doConnect()
            return
        }
        var error: OTError?
        defer {
            processError(error)
        }
        
        session?.publish(publisher, error: &error)
    }
    
    func doUnPublish() {
        var error: OTError?
        defer {
            processError(error)
        }
        
        session?.unpublish(publisher, error: &error)
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
    
    @IBAction func startStopButton(button : UIButton){
        if reachability?.isReachable == true {
            if button.isSelected {
                button.setTitle("START", for: .normal)
                shouldPublishVideo = false
                self.doUnPublish()
            }else{
                button.setTitle("STOP", for: .normal)
                shouldPublishVideo = true
                self.doPublish()
            }
            button.isSelected = !button.isSelected
        }
        else{
            DispatchQueue.main.async {
                let controller = UIAlertController(title: "Error", message: "No Network", preferredStyle: .alert)
                controller.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(controller, animated: true, completion: nil)
            }
        }
    }

    func sessionDidConnect(_ session: OTSession) {
        print("Session connected")
        setTitle(title: "Session connected")
        if shouldPublishVideo {
            self.doPublish()
        }
    }
    
    func sessionDidDisconnect(_ session: OTSession) {
        print("Session disconnected")
        setTitle(title: "Session disconnected")
    }
    
    func session(_ session: OTSession, streamCreated stream: OTStream) {
        print("Session streamCreated: \(stream.streamId)")
        setTitle(title: "Session streamCreated: \(stream.streamId)")
    }
    
    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        print("Session streamDestroyed: \(stream.streamId)")
        setTitle(title: "Session streamDestroyed: \(stream.streamId)")
    }
    
    func session(_ session: OTSession, didFailWithError error: OTError) {
        print("session Failed to connect: \(error.localizedDescription)")
        setTitle(title: "session Failed to connect: \(error.localizedDescription)")
    }
    

// MARK: - OTPublisher delegate callbacks

    func publisher(_ publisher: OTPublisherKit, streamCreated stream: OTStream) {
        print("Publishing")
        setTitle(title: "Publishing")
    }
    
    func publisher(_ publisher: OTPublisherKit, streamDestroyed stream: OTStream) {

        print("streamDestroyed")
        setTitle(title: "streamDestroyed")
    }
    
    func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
        print("Publisher failed: \(error.localizedDescription)")
        setTitle(title: "Publisher failed: \(error.localizedDescription)")
    }
}
