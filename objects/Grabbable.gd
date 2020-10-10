extends RigidBody

onready var backwards_pd: BackwardsPD = $BackwardsPD

var target_basis = null


func _integrate_forces(state):
    if target_basis != null and backwards_pd != null:
        var is_colliding = get_colliding_bodies().size() > 0
        if !is_colliding:
            print('correct')
            ($BackwardsPD as BackwardsPD).set_torque(
                    global_transform.basis.get_rotation_quat(), 
                    target_basis.get_rotation_quat(),
                    state,
                    self,
                    get_colliding_bodies().size() > 0,
                    true
            )


func grab():
    return


func drop():
    target_basis = null
