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

struct MotionData {
    var timestamp : Date
    var acc_x : Double
    var acc_y : Double
    var acc_z : Double
    var rot_x : Double
    var rot_y : Double
    var rot_z : Double
}

func randomMotionData() -> MotionData {
    return MotionData(
        timestamp: Date(),
        acc_x: Double.random(in: -1...1),
        acc_y: Double.random(in: -1...1),
        acc_z: Double.random(in: -1...1),
        rot_x: Double.random(in: -1...1),
        rot_y: Double.random(in: -1...1),
        rot_z: Double.random(in: -1...1))
}

class MotionProvider: ObservableObject {
    private var MotionQueue = OperationQueue.main
    let motionManager = CMMotionManager()
    var fakeMotionTimer : Timer?
    
    @Published private var _running = false
    
    var running: Bool {
        set(newRunning) {
            if newRunning {self.start()}
            else {self.stop()}
        }
        get { return self._running }
    }
    
    public let objectWillChange = PassthroughSubject<MotionData,Never>()
    
    public private(set) var currentMotion: MotionData = MotionData(timestamp: Date(), acc_x: 0, acc_y: 0, acc_z: 0, rot_x: 0, rot_y: 0, rot_z: 0) {
        willSet {
            objectWillChange.send(newValue)
        }
    }
    
    func start() {
        if !self._running {
            if motionManager.isDeviceMotionAvailable {
                print("motion started")
                motionManager.deviceMotionUpdateInterval = ActivityModelConsts.sensorsUpdateInterval
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
                    withTimeInterval: ActivityModelConsts.sensorsUpdateInterval,
                    repeats: true) { timer in
                        
                        self.currentMotion = randomMotionData()
                }
            }
            self._running = true
        }
    }
    
    func stop() {
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
        self._running = false
    }
}
