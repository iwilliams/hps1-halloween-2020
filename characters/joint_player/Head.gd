extends RigidBody

var holding = false


func _ready():
    $RayCast.add_exception($"../Body")


func _physics_process(delta):
    var collider = $RayCast.get_collider()
    if !holding && Input.is_action_just_pressed("grab") && collider is RigidBody:
        var joint := Generic6DOFJoint.new()
        joint.set_node_a(self.get_path())
        joint.set_node_b(collider.get_path())
        joint.set_flag_x(Generic6DOFJoint.FLAG_ENABLE_ANGULAR_LIMIT, false)
        joint.set_flag_y(Generic6DOFJoint.FLAG_ENABLE_ANGULAR_LIMIT, false)
        joint.set_flag_z(Generic6DOFJoint.FLAG_ENABLE_ANGULAR_LIMIT, false)
        (collider as RigidBody).angular_damp = 20
        collider.mode = RigidBody.MODE_RIGID
        collider.add_child(joint)
        holding = joint
    elif holding && Input.is_action_just_pressed("grab"):
        get_node(holding.get_node_b()).angular_damp = -1
        holding.queue_free()
        holding = null
    elif holding && Input.is_action_just_pressed("nail"):
        get_node(holding.get_node_b()).angular_damp = -1
        (get_node(holding.get_node_b()) as RigidBody).mode = RigidBody.MODE_STATIC
        holding.queue_free()
        holding = null
        
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass


func _integrate_forces(state):
    var current_transform = state.transform
    var target_transform = $"../Body/Yaw/Pitch".global_transform
    var next_transform = current_transform.interpolate_with(target_transform, .8)
    state.set_transform(target_transform)
    
    return
#    state.angular_velocity = Vector3.ZERO
#    if abs(mouse_movement.y) > 0:
##        rotate_x(.2)
##        state.set_transform(state.transform.rotated(Vector3.RIGHT, 2))
##        state.angular_velocity.x = mouse_movement.y
#    else:
#        state.angular_velocity.x = 0
    pass
    mouse_movement = Vector2()

var mouse_sensitivity = 1
var mouse_movement = Vector2()
#var free_look = false
#onready var cam = find_node("Pivot")
func _input(event):
    return
    if Input.is_action_just_pressed("ui_cancel"):
        if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
            Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
        else:
            Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    
    if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
        mouse_movement = Vector2(event.relative.x * mouse_sensitivity, event.relative.y * mouse_sensitivity)
