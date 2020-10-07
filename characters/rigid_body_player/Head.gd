extends RigidBody

onready var body = get_node("../Body")
onready var pitch: Spatial = get_node("../Body/Yaw/Pitch")


var kp: float = 1.0
var ki: float = 0.0
var kd: float = 0.1

var prevError = Vector3()
var p = Vector3()
var i = Vector3()
var d = Vector3()

func getOutput(currentError, delta: float):
    p = currentError
    i += p * delta
    d = (p - prevError) / delta
    prevError = currentError
    
    return p*kp + i*ki + d*kd;


func _integrate_forces(state: PhysicsDirectBodyState):
    state.transform.origin = pitch.global_transform.origin
    
    var diff: Quat = global_transform.basis.get_rotation_quat().inverse() * pitch.global_transform.basis.get_rotation_quat()
    var eulers = orientTorque(diff.get_euler())
    var torque = eulers
    if torque.length() < 0.2:
        state.angular_velocity = Vector3.ZERO
    else:
        torque = global_transform.basis.get_rotation_quat() * torque * 20
    #    print(diff.length())
    #    state.angular_velocity = Vector3.ZERO
        add_torque(torque)
    #    add_torque(state.angular_velocity * -1)

#    var diff: Quat = global_transform.basis.get_rotation_quat().inverse() * pitch.global_transform.basis.get_rotation_quat()
#    var eulers = orientTorque(diff.get_euler())
#    var torque = getOutput(eulers, state.step)
#    add_torque(torque)

#    add_torque(orientTorque(getOutput(diff, state.step).normalized().get_euler()))


func orientTorque(torque: Vector3) -> Vector3:
    var newTorque = Vector3(torque.x, torque.y, torque.z)
    if torque.x > 180:
        newTorque = torque.x - 360
    if torque.y > 180:
        newTorque = torque.y - 360
    if torque.z > 180:
        newTorque = torque.z - 360
    return newTorque
