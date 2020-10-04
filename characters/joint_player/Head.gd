extends RigidBody

var holding = null
var holding_joint = null
var grab_by_point = false

func _ready():
    $RayCast.add_exception($"../Body")


func _physics_process(delta):

    var collider = $RayCast.get_collider()
    
    if holding_joint:
        $MeshInstance.global_transform.origin = holding_joint.global_transform.origin
    elif $RayCast.is_colliding():
        $MeshInstance.global_transform.origin = $RayCast.get_collision_point()
        
    if !holding && Input.is_action_just_pressed("grab") && collider is RigidBody:
        var col_point = $RayCast.get_collision_point()
        var joint := Generic6DOFJoint.new()
        joint.set_node_a(self.get_path())
        joint.set_node_b(collider.get_path())
        collider.mode = RigidBody.MODE_RIGID


        if grab_by_point:
            add_child(joint)
            joint.set_flag_x(Generic6DOFJoint.FLAG_ENABLE_ANGULAR_LIMIT, false)
            joint.set_flag_y(Generic6DOFJoint.FLAG_ENABLE_ANGULAR_LIMIT, false)
            joint.set_flag_z(Generic6DOFJoint.FLAG_ENABLE_ANGULAR_LIMIT, false)
            joint.translation = to_local(col_point)
        else:
            collider.add_child(joint)
            (collider as RigidBody).angular_damp = 20
            
        holding_joint = joint
        holding = collider as RigidBody
        holding.gravity_scale = 1
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
        var limit = !grab_by_point && bodies.size() == 0
        holding_joint.set_flag_x(Generic6DOFJoint.FLAG_ENABLE_ANGULAR_LIMIT, limit)
        holding_joint.set_flag_y(Generic6DOFJoint.FLAG_ENABLE_ANGULAR_LIMIT, limit)
        holding_joint.set_flag_z(Generic6DOFJoint.FLAG_ENABLE_ANGULAR_LIMIT, limit)
        

    if ($"../Body/RayCast" as RayCast).get_collider():
        print("on floor")
        axis_lock_linear_y = true
    else:
        axis_lock_linear_y = false


func _integrate_forces(state):
    var current_transform = state.transform
    var target_transform = Transform($"../Body/Yaw/Pitch".global_transform.basis, $"../Body/Yaw/Pitch".global_transform.origin)
#    var next_transform = current_transform.interpolate_with(target_transform, .8)
    state.set_transform(target_transform)
    

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
