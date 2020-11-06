extends Spatial

var break_count = 0

func _get_random_panel():
    var children = get_children()
    var panels = []
    for child in children:
        if child.is_in_group("Panel") && child.mode == RigidBody.MODE_STATIC:
            panels.append(child)
    panels.shuffle()
    return panels.pop_front()
    

func break_roof(b):
    var panel = _get_random_panel()
    if panel == null:
        return
               
    panel.mode = RigidBody.MODE_RIGID
    break_count += 1
    yield(get_tree().create_timer(1.0), "timeout")
    panel.get_child(panel.get_child_count() - 1).queue_free() # Kill joint

    (panel as RigidBody).apply_torque_impulse(panel.global_transform.basis.x.normalized() * -1)
    (panel as RigidBody).apply_central_impulse(panel.global_transform.basis.y.normalized() * 4)
    (panel as RigidBody).set_collision_mask_bit(4, true)
    (panel as RigidBody).set_collision_mask_bit(5, true)
    (panel as RigidBody).set_collision_mask_bit(6, true)