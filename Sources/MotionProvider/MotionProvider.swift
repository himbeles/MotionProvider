//
//  MotionProvider.swift
//
//
//  Created by Luis R on 21.09.19
//  Copyright © 2019 himbeles. All rights reserved.
//

#if !os(macOS)
//#if canImport(CoreMotion)
import CoreMotion
//#endif

import Foundation

import Combine

/**
 A Combine-based CoreMotion data provider.

 On every update of the device motion data (accelerometer and gyroscope), it provides a struct `MotionData`
 through a `PassthroughSubject<MotionData, Never>` called `motionWillChange`, as well as a published property `motion`.

 If real location data is unavailable on the device (e.g., the Simulator), it provides random fake-motion data scheduled by a timer.
*/
public class MotionProvider: ObservableObject {
    private var motionQueue = OperationQueue.main
    let motionManager = CMMotionManager()
    var fakeMotionTimer : Timer?
    
    private let formatter = DateFormatter()
        
    /// The sensor update interval in seconds.
    public var updateInterval : Double
    
    @Published private var _active : Bool
    
    /// Indicates if MotionProvider is querying sensor values.
    public var active: Bool {
        get { self._active }
    }
    
    public init(){
        _active = false
        updateInterval = 0.01 // this is the maximum possible hardware sensor refresh (100Hz) rate as of 2020
        
        formatter.dateFormat = "hh:mm:ss.SSS" //If you dont want static "UTC" you can go for ZZZZ instead of 'UTC'Z.
        formatter.timeZone = TimeZone(abbreviation: "IST")
    }
    
    /// Is emitted when the `currentMotion` property changes.
    public let motionWillChange = PassthroughSubject<MotionData, Never>()
    
    /**
     The current motion data as a `MotionData` struct.
     
     Updates of its value trigger both the `objectWillChange` and the `motionWillChange` PassthroughSubjects.
     */
    @Published public private(set) var motion: MotionData? {
        willSet {
            if let n=newValue {
                motionWillChange.send(n)
            }
        }
    }
    
    /// Start the `MotionProvider` data acquisition.
    public func start() {
        var i = 0
        var rawMotionStartTime : Double = 0
        var startDate : Date = Date()

        
        if !self._active {
            if motionManager.isDeviceMotionAvailable {
                print("motion started")
                motionManager.deviceMotionUpdateInterval = updateInterval
                motionManager.showsDeviceMovementDisplay = true
                motionManager.startDeviceMotionUpdates(using: .xArbitraryZVertical,
                                                       to: motionQueue) { [self] (motion, error) in
                                                        if let motion = motion {
                                                            if (i==0) {
                                                                startDate = Date()
                                                                rawMotionStartTime = motion.timestamp
                                                            }
                                                            
                                                            /// time stamp is calculated as start time from calendar + time delta in seconds from motion sensor
                                                            let timestamp = startDate + (motion.timestamp - rawMotionStartTime)
                                                            
                                                            self.motion = MotionData(
                                                                timestamp: timestamp,
                                                                acc_x: motion.userAcceleration.x,
                                                                acc_y: motion.userAcceleration.y,
                                                                acc_z: motion.userAcceleration.z,
                                                                rot_x: motion.rotationRate.x,
                                                                rot_y: motion.rotationRate.y,
                                                                rot_z: motion.rotationRate.z)
                                                            //print(i, self.formatter.string(from: self.motion!.timestamp))
                                                            i+=1
                                                        }
                }
            }
            else {
                print("fake motion started")
                self.fakeMotionTimer = Timer.scheduledTimer(
                    withTimeInterval: updateInterval,
                    repeats: true) { timer in
                        i+=1
                        var m = randomMotionData()
                        m.timestamp = timer.fireDate
                        self.motion = m
                    
                        //print(i, self.formatter.string(from: self.motion!.timestamp))
                }
            }
            self._active = true
        }
    }
    
    /// stop the `MotionProvider` data acquisition
    public func stop() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.stopDeviceMotionUpdates()
            print("motion stopped")
        }
        else {
            if let timer = self.fakeMotionTimer {
                timer.invalidate()
            }
            print("fake motion stopped")
        }
        self._active = false
    }
}
#endif
