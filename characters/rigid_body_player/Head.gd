extends RigidBody

onready var body = get_node("../Body")
onready var pitch: Spatial = get_node("../Body/Yaw/Pitch")

func _integrate_forces(state: PhysicsDirectBodyState):
    state.transform.origin = pitch.global_transform.origin
    
    var diff: Quat = global_transform.basis.get_rotation_quat().inverse() * pitch.global_transform.basis.get_rotation_quat()
    var eulers = orientTorque(diff.get_euler())
    var torque = eulers
    torque = global_transform.basis.get_rotation_quat() * torque * 20
    state.angular_velocity = Vector3.ZERO
    add_torque(torque)
    add_torque(state.angular_velocity * -1)


func orientTorque(torque: Vector3) -> Vector3:
    var newTorque = Vector3(torque.x, torque.y, torque.z)
    if torque.x > 180:
        newTorque = torque.x - 360
    if torque.y > 180:
        newTorque = torque.y - 360
    if torque.z > 180:
        newTorque = torque.z - 360
    return newTorque
