class_name BackwardsPD
extends Node


export(float) var frequency = 1 setget _set_frequency
func _set_frequency(value):
    frequency = value
    kp = (6*frequency)*(6*frequency)* 0.25


export(float) var damping = 1 setget _set_damping
func _set_damping(value):
    damping = value
    kd = 4.5*frequency*damping

export(float) var threshold = .1

var kp = (6*frequency)*(6*frequency)* 0.25
var kd = 4.5*frequency*damping

export(float) var maximum = 50


func get_rotation_error(current_rotation: Quat, desired_rotation: Quat) -> Quat:
    var error: Quat = desired_rotation * current_rotation.inverse()
    return error


# https://digitalopus.ca/site/pd-controllers/
func set_torque(current_rotation: Quat, desired_rotation: Quat, state: PhysicsDirectBodyState, body: RigidBody, is_colliding := false, debug = false) -> void:   
    kp = (6*frequency)*(6*frequency)* 0.25
    kd = 4.5*frequency*damping
    var dt = state.step
    var g: float = 1 / (1 + kd * dt + kp * dt * dt)
    var ksg: float = kp * g
    var kdg: float = (kd + kp * dt) * g
    var q: Quat = get_rotation_error(current_rotation, desired_rotation)
    
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
    
    if xMag < threshold && !is_colliding:
        state.transform.basis = desired_rotation
            
    x = x.normalized()
    x = Vector3(deg2rad(x.x), deg2rad(x.y), deg2rad(x.z))
    
    var pidv: Vector3 = kp * x * xMag - kd * body.angular_velocity
    var rotInertia2World: Quat = body.global_transform.basis.get_rotation_quat() * body.get_inverse_inertia_tensor().get_rotation_quat() # inverse the inverse?? seems like we need to?
    if debug:
        print(body.get_inverse_inertia_tensor().inverse().get_rotation_quat())
    pidv = rotInertia2World.inverse() * pidv
    pidv *= state.inverse_inertia # inverse the inverse?, doesn't seem like we need to
    pidv = rotInertia2World * pidv
    var tmp_maximum = maximum
    if is_colliding:
        tmp_maximum = 10
    pidv = Vector3(clamp(pidv.x, -tmp_maximum, tmp_maximum), clamp(pidv.y, -tmp_maximum, tmp_maximum), clamp(pidv.z, -tmp_maximum, tmp_maximum))
    body.add_torque(pidv)
