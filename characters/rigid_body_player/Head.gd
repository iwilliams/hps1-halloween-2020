extends RigidBody

onready var body = get_node("../Body")
onready var pitch: Spatial = get_node("../Body/Yaw/Pitch")

var GrabJoint: PackedScene = preload("res://characters/rigid_body_player/GrabJoint.tscn")
var holding
var holding_joint
var og_mass

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
#        error_correct_basic(state)
        error_correct_backwards_pd(state)
        
#        if holding.linear_velocity.y > body.linear_velocity.y:
#            body.add_central_force(Vector3(0, state.linear_velocity.y - holding.linear_velocity.y, 0))
#            print("CORRECT")
#        else:
#            print("NO CORRECT   ")
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
    
    var is_colliding = (holding as RigidBody).get_colliding_bodies().size()
    if xMag < .1 && !is_colliding:
#        print('hard correct')
        state.transform = pitch.global_transform
    else:
        pass
#        print("PD")
    
    x = x.normalized()
    x = Vector3(deg2rad(x.x), deg2rad(x.y), deg2rad(x.z))
    

    var pidv: Vector3 = kp * x * xMag - kd * angular_velocity
    var rotInertia2World: Quat = global_transform.basis.get_rotation_quat() * get_inverse_inertia_tensor().inverse().get_rotation_quat() # inverse the inverse??
    pidv = rotInertia2World.inverse() * pidv
    pidv *= state.inverse_inertia # inverse the inverse?
    pidv = rotInertia2World * pidv
    var maximum = 50
    if is_colliding:
        maximum = 10
    pidv = Vector3(clamp(pidv.x, -maximum, maximum), clamp(pidv.y, -maximum, maximum), clamp(pidv.z, -maximum, maximum))
    add_torque(pidv)
    pass
    

func error_correct_basic(state: PhysicsDirectBodyState) -> void:
    var diff: Quat = get_rotation_error()
    var eulers = orientTorque(diff.get_euler())
    var torque = eulers
    if torque.length() < 0.2:
        state.angular_velocity = Vector3.ZERO
    else:
        torque = global_transform.basis.get_rotation_quat() * torque * 20
    add_torque(torque)


func _physics_process(delta):
    var collider = $RayCast.get_collider()
            
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
        holding.grab()
        holding.target_basis = joint.global_transform.basis
        og_mass = holding.mass
        holding.mass = 1
        mode = RigidBody.MODE_RIGID
#        holding.mass = 1
    elif holding && Input.is_action_just_pressed("grab"):
        holding.angular_damp = -1
        holding.mass = og_mass
        holding.drop()
#        holding.mode = RigidBody.MODE_RIGID
        holding.gravity_scale = 1
        holding_joint.queue_free()
        holding = null
        holding_joint = null
        mode = RigidBody.MODE_CHARACTER
    elif holding && Input.is_action_just_pressed("nail"):
        holding.mass = og_mass
        holding.angular_damp = -1
        holding.drop()
        holding.mode = RigidBody.MODE_STATIC
        holding_joint.queue_free()
        holding = null
        holding_joint = null
        mode = RigidBody.MODE_CHARACTER


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
