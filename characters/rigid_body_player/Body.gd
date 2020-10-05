extends RigidBody

var is_on_floor = false

var dir = Vector3.ZERO
var speed = 5
var accel = 50
var accel_air = 7

var height = 1.3


func _ready():
    pass


func _integrate_forces(state):
    if Input.is_action_just_pressed("jump"):
        state.linear_velocity.y += 6
    elif $RayCast.is_colliding():
        is_on_floor = true
        var target_velocity = dir.normalized() * speed
        var old_y = state.linear_velocity.y
        state.linear_velocity = state.linear_velocity.move_toward(target_velocity, state.step * accel)
        state.linear_velocity.y = old_y
        var col = $RayCast.get_collision_point()
        var proper_origin = stepify(col.y, 0.01)
        if state.linear_velocity.y <= 0 and abs(state.transform.origin.y - proper_origin) > .01: 
            state.transform.origin.y = proper_origin
    else:
        is_on_floor = false
#        state.linear_velocity.y += -9.8 * 2 * state.step
        var target_velocity = dir.normalized() * speed
        var old_y = state.linear_velocity.y
        state.linear_velocity = state.linear_velocity.move_toward(target_velocity, state.step * accel_air)
        state.linear_velocity.y = old_y



func _process(delta):
    var base_transform = $Yaw.global_transform
    dir = Vector3.ZERO
    dir += base_transform.basis.z.normalized() * Input.get_action_strength("move_forward")
    dir -= base_transform.basis.z.normalized() * Input.get_action_strength("move_backward")
    dir += base_transform.basis.x.normalized() * Input.get_action_strength("move_left")
    dir -= base_transform.basis.x.normalized() * Input.get_action_strength("move_right")
