//
//  MotionProvider.swift
//
//
//  Created by Luis on 21.09.19.
//  Copyright © 2019 himbeles. All rights reserved.
//

import Foundation
import CoreMotion
import Combine

/// Struct that holds userAcceleration and rotationRate data from accelerometer and gyroscope
public struct MotionData {
    public var timestamp : Date
    public var acc_x : Double // userAcceleration.x
    public var acc_y : Double // userAcceleration.y
    public var acc_z : Double // userAcceleration.z
    public var rot_x : Double // rotationRate.x
    public var rot_y : Double // rotationRate.y
    public var rot_z : Double // rotationRate.z
}

/// Generate `MotionData` with random values
public func randomMotionData() -> MotionData {
    return MotionData(
        timestamp: Date(),
        acc_x: Double.random(in: -1...1),
        acc_y: Double.random(in: -1...1),
        acc_z: Double.random(in: -1...1),
        rot_x: Double.random(in: -1...1),
        rot_y: Double.random(in: -1...1),
        rot_z: Double.random(in: -1...1))
}

/**
 A Combine-based CoreMotion data provider as a Swift Package

 On every update of the device motion data (accelerometer and gyroscope), it provides a struct `MotionData`
 through a `PassthroughSubject<MotionData, Never>` called `motionWillChange`.

 If real location data is unavailable on the device (e.g., the Simulator), it provides random fake-motion data scheduled by a timer.
*/
public class MotionProvider: ObservableObject {
    private var motionQueue = OperationQueue.main
    let motionManager = CMMotionManager()
    var fakeMotionTimer : Timer?
    
    /// the sensor update interval in seconds
    public var updateInterval : Double
    
    @Published private var _active : Bool
    
    /// indicates if MotionProvider is querying sensor values
    public var active: Bool {
        get { self._active }
    }
    
    public init(){
        _active = false
        updateInterval = 0.05 // this is the maximum possible hardware sensor refresh rate as of 2020
    }
    
    public let motionWillChange = PassthroughSubject<MotionData, Never>()
    
    /// the current motion data reading as a `MotionData` struct
    @Published public private(set) var currentMotion: MotionData? {
        willSet {
            if let n=newValue {
                motionWillChange.send(n)
            }
        }
    }
    
    /// start the `MotionProvider` data acquisition
    public func start() {
        if !self._active {
            if motionManager.isDeviceMotionAvailable {
                print("motion started")
                motionManager.deviceMotionUpdateInterval = updateInterval
                motionManager.showsDeviceMovementDisplay = true
                motionManager.startDeviceMotionUpdates(using: .xArbitraryZVertical,
                                                       to: motionQueue) { (motion, error) in
                                                        if let motion = motion {
                                                            self.currentMotion = MotionData(
                                                                timestamp: Date(),
                                                                acc_x: motion.userAcceleration.x,
                                                                acc_y: motion.userAcceleration.y,
                                                                acc_z: motion.userAcceleration.z,
                                                                rot_x: motion.rotationRate.x,
                                                                rot_y: motion.rotationRate.y,
                                                                rot_z: motion.rotationRate.z)
                                                        }
                }
            }
            else {
                print("fake motion started")
                
                self.fakeMotionTimer = Timer.scheduledTimer(
                    withTimeInterval: updateInterval,
                    repeats: true) { timer in
                        
                        self.currentMotion = randomMotionData()
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
            if let timer = self.fakeMotionTimer{
                timer.invalidate()
            }
            print("fake motion stopped")
        }
        self._active = false
    }
}
