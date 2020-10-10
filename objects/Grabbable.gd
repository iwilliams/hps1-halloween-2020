extends RigidBody
var target_basis

func _physics_process(delta):
    var bodies = get_colliding_bodies()
    var limit = bodies.size() == 0
    limit = false
    if has_node("Generic6DOFJoint"):
        $Generic6DOFJoint.set_flag_x(Generic6DOFJoint.FLAG_ENABLE_ANGULAR_LIMIT, limit)
        $Generic6DOFJoint.set_flag_y(Generic6DOFJoint.FLAG_ENABLE_ANGULAR_LIMIT, limit)
        $Generic6DOFJoint.set_flag_z(Generic6DOFJoint.FLAG_ENABLE_ANGULAR_LIMIT, limit)
#    if limit:
#        $Generic6DOFJoint.set_param_x(Generic6DOFJoint.PARAM_LINEAR_UPPER_LIMIT, 0)
#    else:
#        $Generic6DOFJoint.set_param_x(Generic6DOFJoint.PARAM_LINEAR_UPPER_LIMIT, 1)


func grab():
    target_basis = global_transform.basis


func drop():
    target_basis = null
