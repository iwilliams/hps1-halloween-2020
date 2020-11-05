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
    

func break_wall(b):
    var panel = _get_random_panel()
    if panel == null:
        return
        
        
    var panel_local_pos = panel.transform.origin
    var panel_local_pos_target = panel_local_pos - Vector3(0, 0, 1)
    
    var panel_g_pos = to_global(panel_local_pos)
    var panel_g_pos_target = to_global(panel_local_pos_target)
    
    var impulse_dir = panel_g_pos_target - panel_g_pos
    
    panel.mode = RigidBody.MODE_RIGID
    (panel as RigidBody).apply_central_impulse(impulse_dir * 1)
    break_count += 1
    yield(get_tree().create_timer(1.0), "timeout")
    panel.get_child(panel.get_child_count() - 1).queue_free()

    (panel as RigidBody).apply_torque_impulse(panel.global_transform.basis.x.normalized())
    (panel as RigidBody).apply_central_impulse(impulse_dir * 2)


func _ready():
    for child in get_children():
        if child.is_in_group("Panel"):
            $WallFrame.add_collision_exception_with(child)