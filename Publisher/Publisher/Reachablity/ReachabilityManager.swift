//
//  ReachabilityManager.swift
//  BaseProjectStructure
//
//  Created by Amruthaprasad on 25/01/16.
//  Copyright © 2016 Amruthaprasad. All rights reserved.
//

import UIKit

class ReachabilityManager: NSObject {
    
    private static var __once: () = {
            Static.instance = ReachabilityManager()
        }()
    
    var reachability : Reachability?
    
    struct Static {
        static var onceToken: Int = 0
        static var instance: ReachabilityManager? = nil
    }


    //MARK: Default Manager
    class var sharedManager: ReachabilityManager {
//        struct Static {
//            static var onceToken: Int = 0
//            static var instance: ReachabilityManager? = nil
//        }
        _ = ReachabilityManager.__once
        return Static.instance!
    }
    
    //MARK: Class Methods
    static func isReachable() -> Bool{
    return ReachabilityManager.sharedManager.reachability!.isReachable
    }
    
    static func isUnreachable() -> Bool {
    return !(ReachabilityManager.sharedManager.reachability!.isReachable)
    }
    
    static func isReachableViaWWAN() -> Bool{
    return ReachabilityManager.sharedManager.reachability!.isReachableViaWWAN
    }
    
    static func isReachableViaWiFi() ->Bool{
    return ReachabilityManager.sharedManager.reachability!.isReachableViaWiFi
    }

    //MARK: Private Initialization
    override init() {
        do {
            // Initialize Reachability
            self.reachability = Reachability.init()
            
            // Start Monitoring
            try self.reachability?.startNotifier()
            
        } catch {
            print("Unable to create Reachability")
            return
        }

    }
}

