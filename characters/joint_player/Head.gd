extends RigidBody

var holding = null
var holding_joint = null


func _ready():
    $RayCast.add_exception($"../Body")


func _physics_process(delta):
    var collider = $RayCast.get_collider()
    if !holding && Input.is_action_just_pressed("grab") && collider is RigidBody:
        var joint := Generic6DOFJoint.new()
        joint.set_node_a(self.get_path())
        joint.set_node_b(collider.get_path())
#        joint.set_flag_x(Generic6DOFJoint.FLAG_ENABLE_ANGULAR_LIMIT, false)
#        joint.set_flag_y(Generic6DOFJoint.FLAG_ENABLE_ANGULAR_LIMIT, false)
#        joint.set_flag_z(Generic6DOFJoint.FLAG_ENABLE_ANGULAR_LIMIT, false)
        (collider as RigidBody).angular_damp = 20
        collider.mode = RigidBody.MODE_RIGID
        collider.add_child(joint)
        holding_joint = joint
        holding = collider as RigidBody
        holding.gravity_scale = 0
#        holding.mass = 1
    elif holding && Input.is_action_just_pressed("grab"):
        holding.angular_damp = -1
#        holding.mass = 1
#        holding.mode = RigidBody.MODE_RIGID
        holding.gravity_scale = 1
        holding_joint.queue_free()
        holding = null
        holding_joint = null
    elif holding && Input.is_action_just_pressed("nail"):
        holding.mass = 1
        holding.angular_damp = -1
        holding.mode = RigidBody.MODE_STATIC
        holding_joint.queue_free()
        holding = null
        holding = null
        
    if holding:
        var hold_rb := holding as RigidBody
        var bodies = hold_rb.get_colliding_bodies()
        var limit = bodies.size() == 0
        holding_joint.set_flag_x(Generic6DOFJoint.FLAG_ENABLE_ANGULAR_LIMIT, limit)
        holding_joint.set_flag_y(Generic6DOFJoint.FLAG_ENABLE_ANGULAR_LIMIT, limit)
        holding_joint.set_flag_z(Generic6DOFJoint.FLAG_ENABLE_ANGULAR_LIMIT, limit)
        

        
    if ($"../Body/RayCast" as RayCast).get_collider():
        print("on floor")
        axis_lock_linear_y = true
    else:
        axis_lock_linear_y = false

        
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass


func _integrate_forces(state):
    var current_transform = state.transform
    var target_transform = Transform($"../Body/Yaw/Pitch".global_transform.basis, $"../Body/Yaw/Pitch".global_transform.origin)
#    var next_transform = current_transform.interpolate_with(target_transform, .8)
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
