# MotionProvider

A `Combine`-based CoreMotion data provider.

On every update of the location, it provides a struct    
```
struct MotionData {
    var timestamp : Date
    var acc_x : Double
    var acc_y : Double
    var acc_z : Double
    var rot_x : Double
    var rot_y : Double
    var rot_z : Double
}
```
as a PassthroughSubject. 

If real location data is unavailable on the device (e.g., the Simulator), it provides random fake-motion data scheduled by a timer. 
