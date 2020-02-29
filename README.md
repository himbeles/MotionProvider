# MotionProvider

A `Combine`-based CoreMotion data provider.

On every update of the device motion data, it provides a struct    

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
through a `PassthroughSubject<MotionData, Never>` called `motionWillChange`. 

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
    handleMotion(motionData: md)
}
```

The function `handleMotion` in the `sink` closure is executed on every `MotionData` object send by the `MotionProvider`.


### Stopping the Motion Provider

Stop the `MotionProvider` and cancel the subscription

```swift
motionProvider.stop()
cancellableMotion?.cancel()
```
