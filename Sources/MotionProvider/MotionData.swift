//
//  File.swift
//  
//
//  Created by Luis on 17.10.20.
//

import Foundation

/// Holds userAcceleration and rotationRate data from accelerometer and gyroscope
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
