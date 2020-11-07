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
#    var joint := Generic6DOFJoint.new()
    joint.set_node_a(self.get_path())
    joint.set_node_b(to_grab.get_path())
    joint.set_flag_x(Generic6DOFJoint.FLAG_ENABLE_ANGULAR_LIMIT, false)
    joint.set_flag_y(Generic6DOFJoint.FLAG_ENABLE_ANGULAR_LIMIT, false)
    joint.set_flag_z(Generic6DOFJoint.FLAG_ENABLE_ANGULAR_LIMIT, false)
    to_grab.mode = RigidBody.MODE_RIGID
    to_grab.add_child(joint)
    $HoldPosition.global_transform = to_grab.global_transform
    holding_joint = joint
    holding = to_grab
    holding.gravity_scale = 0
    og_mass = holding.mass
    holding.mass = 1
    mode = RigidBody.MODE_RIGID
    if holding.has_method("grab"):
        holding.grab()
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
    if !holding && Input.is_action_just_pressed("grab") && collider is Grabbalbe && collider.can_grab():
        state.transform = state.transform.looking_at(collider.global_transform.origin, Vector3.UP)
        grab_on_next_frame = collider
        return
    elif holding && Input.is_action_just_pressed("grab"):
        drop()
        mode = RigidBody.MODE_CHARACTER
    elif holding && Input.is_action_just_pressed("nail") && holding.can_weld():
        holding.mode = RigidBody.MODE_STATIC
        if holding.has_method("nail"):
            holding.nail()
        drop()
        mode = RigidBody.MODE_CHARACTER

    if mode == RigidBody.MODE_RIGID:
        state.transform.origin = pitch.global_transform.origin
        var colliding = holding != null and (holding.treat_as_colliding or (holding as RigidBody).get_colliding_bodies().size() > 0)
        if colliding and state.transform.basis.z.dot(pitch.global_transform.basis.z) < .5:
            drop()
            print("force drop")
            return
        ($BackwardsPD as BackwardsPD).set_torque(
                state.transform.basis.get_rotation_quat(), 
                pitch.global_transform.basis.get_rotation_quat(),
                state,
                self,
                colliding
        )
    else:
        state.transform = pitch.global_transform
        
    if holding:
        $HoldPosition.global_transform.origin = holding.global_transform.origin
        holding.target_basis = $HoldPosition.global_transform.basis
