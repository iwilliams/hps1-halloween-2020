extends RigidBody

onready var body = get_node("../Body")
onready var pitch: Spatial = get_node("../Body/Yaw/Pitch")

var GrabJoint: PackedScene = preload("res://characters/rigid_body_player/GrabJoint.tscn")
var holding
var holding_joint

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
    if mode == RigidBody.MODE_RIGID:
        state.transform.origin = pitch.global_transform.origin
        
        var diff: Quat = global_transform.basis.get_rotation_quat().inverse() * pitch.global_transform.basis.get_rotation_quat()
        var eulers = orientTorque(diff.get_euler())
        var torque = eulers
        if torque.length() < 0.2:
            state.angular_velocity = Vector3.ZERO
        else:
            torque = global_transform.basis.get_rotation_quat() * torque * 20
            
        add_torque(torque)
        
        #    print(diff.length())
        #    state.angular_velocity = Vector3.ZERO

        #    add_torque(state.angular_velocity * -1)

        #    var diff: Quat = global_transform.basis.get_rotation_quat().inverse() * pitch.global_transform.basis.get_rotation_quat()
        #    var eulers = orientTorque(diff.get_euler())
        #    var torque = getOutput(eulers, state.step)
        #    add_torque(torque)

        #    add_torque(orientTorque(getOutput(diff, state.step).normalized().get_euler()))
    else:
        state.transform = pitch.global_transform


func _physics_process(delta):
    var collider = $RayCast.get_collider()
    
#    if holding_joint:
#        $MeshInstance.global_transform.origin = holding_joint.global_transform.origin
#    elif $RayCast.is_colliding():
#        $MeshInstance.global_transform.origin = $RayCast.get_collision_point()
        
    if !holding && Input.is_action_just_pressed("grab") && collider is RigidBody:
        var col_point = $RayCast.get_collision_point()
        var joint := GrabJoint.instance()
        joint.set_node_a(self.get_path())
        joint.set_node_b(collider.get_path())
        collider.mode = RigidBody.MODE_RIGID
        var grab_by_point = true

        if grab_by_point:
            collider.add_child(joint)
            joint.set_flag_x(Generic6DOFJoint.FLAG_ENABLE_ANGULAR_LIMIT, false)
            joint.set_flag_y(Generic6DOFJoint.FLAG_ENABLE_ANGULAR_LIMIT, false)
            joint.set_flag_z(Generic6DOFJoint.FLAG_ENABLE_ANGULAR_LIMIT, false)
            joint.translation = collider.to_local(col_point)
        else:
            collider.add_child(joint)
            (collider as RigidBody).angular_damp = 20
            
        holding_joint = joint
        holding = collider as RigidBody
        holding.gravity_scale = 0
        mode = RigidBody.MODE_RIGID
#        holding.mass = 1
    elif holding && Input.is_action_just_pressed("grab"):
        holding.angular_damp = -1
#        holding.mass = 1
#        holding.mode = RigidBody.MODE_RIGID
        holding.gravity_scale = 1
        holding_joint.queue_free()
        holding = null
        holding_joint = null
        mode = RigidBody.MODE_CHARACTER
    elif holding && Input.is_action_just_pressed("nail"):
        holding.mass = 1
        holding.angular_damp = -1
        holding.mode = RigidBody.MODE_STATIC
        holding_joint.queue_free()
        holding = null
        holding_joint = null
        mode = RigidBody.MODE_CHARACTER


func orientTorque(torque: Vector3) -> Vector3:
    var newTorque = Vector3(torque.x, torque.y, torque.z)
    if torque.x > 180:
        newTorque = torque.x - 360
    if torque.y > 180:
        newTorque = torque.y - 360
    if torque.z > 180:
        newTorque = torque.z - 360
    return newTorque
