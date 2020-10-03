extends RigidBody


var dir = Vector3.ZERO
var speed = 5
var accel = 50

func _integrate_forces(state):
    if self.mode == RigidBody.MODE_KINEMATIC:
        state.transform.origin += dir * speed * state.step
    else:
        var target_velocity = dir * speed
        var old_y = state.linear_velocity.y
        state.linear_velocity = state.linear_velocity.move_toward(target_velocity, state.step * accel)
        state.linear_velocity.y = old_y
        
        print($RayCast.is_colliding())

        if $RayCast.is_colliding():
            var col = $RayCast.get_collision_point()
            print(col.y)
            state.transform.origin.y = stepify(col.y, 0.01) + .8
        else:
            state.linear_velocity.y += -9.8 * 2 * state.step
            
    return
#    angular_velocity = state.angular_velocity.move_toward(Vector3(0, -1 * mouse_movement.x * 100000, 0), state.step * 200)
#    state.linear_velocity = dir
#    mouse_movement = Vector2()
#    pass

func _process(delta):
#    dir.z = Input.get_action_strength("move_forwards")
    var base_transform = $Yaw.global_transform
    dir = Vector3.ZERO
    dir += base_transform.basis.z.normalized() * Input.get_action_strength("move_forward")
    dir -= base_transform.basis.z.normalized() * Input.get_action_strength("move_backward")
    dir += base_transform.basis.x.normalized() * Input.get_action_strength("move_left")
    dir -= base_transform.basis.x.normalized() * Input.get_action_strength("move_right")
#    print(dir)
    pass

var mouse_sensitivity = 1
var mouse_movement = Vector2()
#var free_look = false
#onready var cam = find_node("Pivot")
func _input(event):
    return
    if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
        mouse_movement = Vector2(event.relative.x * mouse_sensitivity, event.relative.y * mouse_sensitivity)
