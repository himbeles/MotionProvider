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

public struct MotionData {
    public var timestamp : Date
    public var acc_x : Double
    public var acc_y : Double
    public var acc_z : Double
    public var rot_x : Double
    public var rot_y : Double
    public var rot_z : Double
}

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

public class MotionProvider: ObservableObject {
    private var MotionQueue = OperationQueue.main
    let motionManager = CMMotionManager()
    var fakeMotionTimer : Timer?
    public var updateInterval : Double
    
    @Published private var _active : Bool
    
    public var active: Bool {
        get { self._active }
    }
    
    public init(){
        _active = false
        updateInterval = 0.05
    }
    
    public let motionWillChange = PassthroughSubject<MotionData, Never>()
        
    @Published public private(set) var currentMotion: MotionData? {
        willSet {
            if let n=newValue {
                motionWillChange.send(n)
            }
        }
    }
    
    public func start() {
        if !self._active {
            if motionManager.isDeviceMotionAvailable {
                print("motion started")
                motionManager.deviceMotionUpdateInterval = updateInterval
                motionManager.showsDeviceMovementDisplay = true
                motionManager.startDeviceMotionUpdates(using: .xArbitraryZVertical,
                                                       to: MotionQueue) { (motion, error) in
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
