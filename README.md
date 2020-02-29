# MotionProvider

A Combine-based CoreMotion data provider as a Swift Package.

On every update of the device motion data (accelerometer and gyroscope), it provides a struct    

```swift
struct MotionData {
    var timestamp : Date
    var acc_x : Double // userAcceleration.x
    var acc_y : Double // userAcceleration.y
    var acc_z : Double // userAcceleration.z
    var rot_x : Double // rotationRate.x
    var rot_y : Double // rotationRate.y
    var rot_z : Double // rotationRate.z
}
```
through a `PassthroughSubject<MotionData, Never>` called `motionWillChange`, as well as a published property `motion`.

If real location data is unavailable on the device (e.g., the Simulator), it provides random fake-motion data scheduled by a timer. 


## Usage

### Starting the Motion Provider

Initialize and start the MotionProvider

```swift
let motionProvider = MotionProvider()
motionProvider.start()
```
### Handling the Motion Data

Subscribe to the `motionWillChange` subject and store the returned `Cancellable`

```swift
cancellableMotion = motionProvider.motionWillChange.sink { md in
    handleMotion(md)
}
```

The function `handleMotion` in the `sink` closure is executed on every `MotionData` object sent by the `MotionProvider`.

Also, the `MotionProvider` is an ObservableObject which has a published property `motion` that updates the ObservableObject.
This dynamic property can directly be accessed in SwiftUI.

### Stopping the Motion Provider

Stop the `MotionProvider` and cancel the subscription

```swift
motionProvider.stop()
cancellableMotion?.cancel()
```
