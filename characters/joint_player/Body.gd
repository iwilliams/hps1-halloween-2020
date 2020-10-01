extends RigidBody


var dir = Vector3.ZERO



func _integrate_forces(state):
    var target_velocity = dir * 50
    state.linear_velocity = state.linear_velocity.move_toward(target_velocity, state.step * 20)
    return
    angular_velocity = state.angular_velocity.move_toward(Vector3(0, -1 * mouse_movement.x * 100000, 0), state.step * 200)
#    state.linear_velocity = dir
    mouse_movement = Vector2()
    pass

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
