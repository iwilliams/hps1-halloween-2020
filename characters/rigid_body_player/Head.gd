extends RigidBody

onready var body = get_node("../Body")
onready var pitch: Spatial = get_node("../Body/Yaw/Pitch")

var GrabJoint: PackedScene = preload("res://characters/rigid_body_player/GrabJoint.tscn")
var holding
var holding_joint
var og_mass

var grab_on_next_frame

func grab(to_grab: RigidBody):
    var joint := GrabJoint.instance()
    joint.set_node_a(self.get_path())
    joint.set_node_b(to_grab.get_path())
    joint.set_flag_x(Generic6DOFJoint.FLAG_ENABLE_ANGULAR_LIMIT, false)
    joint.set_flag_y(Generic6DOFJoint.FLAG_ENABLE_ANGULAR_LIMIT, false)
    joint.set_flag_z(Generic6DOFJoint.FLAG_ENABLE_ANGULAR_LIMIT, false)
    to_grab.mode = RigidBody.MODE_RIGID
    to_grab.add_child(joint)
    holding_joint = joint
    holding = to_grab
    holding.gravity_scale = 0
    og_mass = holding.mass
    holding.mass = 1
    mode = RigidBody.MODE_RIGID
    $InteractPlayer.play(0)
    
    
func drop():
    holding.angular_damp = -1
    holding.mass = og_mass
    holding.gravity_scale = 1
    holding.drop()
    holding.remove_child(holding_joint)
    holding_joint.queue_free()
    holding = null
    holding_joint = null


func _integrate_forces(state: PhysicsDirectBodyState):
    var collider = $RayCast.get_collider()
    
    if grab_on_next_frame != null:
        grab(grab_on_next_frame)
        grab_on_next_frame = null
        return
            
    if !holding && Input.is_action_just_pressed("grab") && collider is RigidBody:
        state.transform = state.transform.looking_at(collider.global_transform.origin, Vector3.UP)
        grab_on_next_frame = collider
        return
    elif holding && Input.is_action_just_pressed("grab"):
        drop()
        mode = RigidBody.MODE_CHARACTER
    elif holding && Input.is_action_just_pressed("nail"):
        holding.mode = RigidBody.MODE_STATIC
        drop()
        mode = RigidBody.MODE_CHARACTER
    if mode == RigidBody.MODE_RIGID:
        state.transform.origin = pitch.global_transform.origin
        error_correct_backwards_pd(state)
    else:
        state.transform = pitch.global_transform


# https://digitalopus.ca/site/pd-controllers/
func error_correct_backwards_pd(state: PhysicsDirectBodyState) -> void:
    var frequency = 60
    var damping = .5
    
    var kp = (6*frequency)*(6*frequency)* 0.25
    var kd = 4.5*frequency*damping
    var dt = state.step
    var g: float = 1 / (1 + kd * dt + kp * dt * dt)
    var ksg: float = kp * g
    var kdg: float = (kd + kp * dt) * g
    var q: Quat = get_rotation_error()
    
    if q.w < 0:
        q.x = -q.x
        q.y = -q.y
        q.z = -q.z
        q.w = -q.w

    var x := Vector3()
    var xMag: float
        
    # https://www.euclideanspace.com/maths/geometry/rotations/conversions/quaternionToAngle/index.htm
    var q1: Quat = Quat(q.x, q.y, q.z, q.w)
    if q1.w > 1:
        q1 = q1.normalized() # if w>1 acos and sqrt will produce errors, this cant happen if quaternion is normalised
    xMag = 2 * acos(q1.w);
    var s: float = sqrt(1-q1.w*q1.w); # assuming quaternion normalised then w is less than 1, so term always positive.
    if s < 0.001: # test to avoid divide by zero, s is always positive due to sqrt
        # if s close to zero then direction of axis not important
        x = Vector3(q1.x, q1.y, q1.z) # if it is important that axis is normalised then replace with x=1; y=z=0;
    else:
        x = Vector3(q1.x / s, q1.y / s, q1.z / s)
    
    var is_colliding = holding != null and (holding as RigidBody).get_colliding_bodies().size()
    if xMag < .1 && !is_colliding:
        state.transform = pitch.global_transform
    
    x = x.normalized()
    x = Vector3(deg2rad(x.x), deg2rad(x.y), deg2rad(x.z))
    
    var pidv: Vector3 = kp * x * xMag - kd * angular_velocity
    var rotInertia2World: Quat = global_transform.basis.get_rotation_quat() * get_inverse_inertia_tensor().inverse().get_rotation_quat() # inverse the inverse?? seems like we need to?
    pidv = rotInertia2World.inverse() * pidv
    pidv *= state.inverse_inertia # inverse the inverse?, doesn't seem like we need to
    pidv = rotInertia2World * pidv
    var maximum = 50
    if is_colliding:
        maximum = 10
    pidv = Vector3(clamp(pidv.x, -maximum, maximum), clamp(pidv.y, -maximum, maximum), clamp(pidv.z, -maximum, maximum))
    add_torque(pidv)
    

func error_correct_basic(state: PhysicsDirectBodyState) -> void:
    var diff: Quat = get_rotation_error()
    var eulers = orientTorque(diff.get_euler())
    var torque = eulers
    if torque.length() < 0.2:
        state.angular_velocity = Vector3.ZERO
    else:
        torque = global_transform.basis.get_rotation_quat() * torque * 20
    add_torque(torque)


func get_rotation_error() -> Quat:
    var diff: Quat = pitch.global_transform.basis.get_rotation_quat() * global_transform.basis.get_rotation_quat().inverse()
    return diff


func orientTorque(torque: Vector3) -> Vector3:
    var newTorque = Vector3(torque.x, torque.y, torque.z)
    if torque.x > 180:
        newTorque = torque.x - 360
    if torque.y > 180:
        newTorque = torque.y - 360
    if torque.z > 180:
        newTorque = torque.z - 360
    return newTorque
