extends RigidBody
var target_basis

func _physics_process(delta):
    var bodies = get_colliding_bodies()
    var limit = bodies.size() == 0
    if has_node("Generic6DOFJoint"):
        $Generic6DOFJoint.set_flag_x(Generic6DOFJoint.FLAG_ENABLE_ANGULAR_LIMIT, limit)
        $Generic6DOFJoint.set_flag_y(Generic6DOFJoint.FLAG_ENABLE_ANGULAR_LIMIT, limit)
        $Generic6DOFJoint.set_flag_z(Generic6DOFJoint.FLAG_ENABLE_ANGULAR_LIMIT, limit)
#    if limit:
#        $Generic6DOFJoint.set_param_x(Generic6DOFJoint.PARAM_LINEAR_UPPER_LIMIT, 0)
#    else:
#        $Generic6DOFJoint.set_param_x(Generic6DOFJoint.PARAM_LINEAR_UPPER_LIMIT, 1)


func grab():
    target_basis = global_transform.basis


func drop():
    target_basis = null
    
func _integrate_forces(state: PhysicsDirectBodyState):
#    if target_basis != null:
#        state.transform.basis = target_basis
    pass
#    var col = state.get_contact_count()
#    print(col)
#    if col > 0:
#        mass = .01
#    else:
#        mass = 1
#    var pitch = get_node("../Player/Body/Yaw/Pitch")
#    var diff: Quat = global_transform.basis.get_rotation_quat().inverse() * pitch.global_transform.basis.get_rotation_quat()
#    var eulers = orientTorque(diff.get_euler())
#    var torque = eulers
#    torque = global_transform.basis.get_rotation_quat() * torque
#    state.angular_velocity = Vector3.ZERO
#    add_torque(torque)
#    add_torque(state.angular_velocity * -1)

    
func orientTorque(torque: Vector3) -> Vector3:
    var newTorque = Vector3(torque.x, torque.y, torque.z)
    if torque.x > 180:
        newTorque = torque.x - 360
    if torque.y > 180:
        newTorque = torque.y - 360
    if torque.z > 180:
        newTorque = torque.z - 360
    return newTorque
