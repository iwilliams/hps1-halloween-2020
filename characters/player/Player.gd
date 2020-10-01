extends RigidBody


var dir = Vector3.ZERO



func _integrate_forces(state):
#    pass
#    print(dir)
#    state.linear_velocity = Vector3(1, 0, 0)
    var target_velocity = dir * 50
#    $"../Plank".target_velocity = target_velocity
    state.linear_velocity = state.linear_velocity.move_toward(target_velocity, state.step * 20)

#    angular_velocity = state.angular_velocity.move_toward(Vector3(0, mouse_movement.x * 100, 0), state.step * 20)
#    state.linear_velocity = dir
    pass

func _process(delta):
#    dir.z = Input.get_action_strength("move_forwards")
    dir = Vector3.ZERO
    dir += global_transform.basis.z.normalized() * Input.get_action_strength("move_forward")
    dir -= global_transform.basis.z.normalized() * Input.get_action_strength("move_backward")
    dir += global_transform.basis.x.normalized() * Input.get_action_strength("move_left")
    dir -= global_transform.basis.x.normalized() * Input.get_action_strength("move_right")
#    print(dir)
    pass

func _physics_process(delta):
#    rotate_object_local(Vector3.UP, mouse_movement.x * -1 * delta)
    var torque_thrust_delta = 280 * delta
    var torque = angular_velocity * -2 * (1-.2)
#
    if abs(mouse_movement.x) > 0:
        torque += global_transform.basis.y.normalized() * torque_thrust_delta * mouse_movement.x * -1
    mouse_movement = Vector2()
    add_torque(torque)
    
#    rotate(Vector3.UP, -mouse_movement.x * delta)
#    mouse_movement = Vector2()

##    if linear_velocity
#    var center = lerp(global_transform.origin, $"../Plank".global_transform.origin, .5)
#    apply_impulse(to_local(center), dir)
#    apply_central_impulse(dir)
#    var torque = angular_velocity * -2 * (1-.2)
#    add_torque(torque)
    pass


var mouse_sensitivity = 1
var mouse_movement = Vector2()
#var free_look = false
#onready var cam = find_node("Pivot")
func _input(event):
    if Input.is_action_just_pressed("ui_cancel"):
        if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
            Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
        else:
            Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    
#    if free_look && event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
#        var movement = event.relative
#        cam.rotation.x += deg2rad(movement.y * mouse_sensitivity)
#        cam.rotation.x = clamp(cam.rotation.x, deg2rad(-45), deg2rad(45))
#        cam.rotation.y += -deg2rad(movement.x * mouse_sensitivity)
#        cam.rotation.y = clamp(cam.rotation.y, deg2rad(-45), deg2rad(45))
    
    if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
        mouse_movement = Vector2(event.relative.x * mouse_sensitivity, event.relative.y * mouse_sensitivity)
