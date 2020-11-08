extends Frame
class_name WindowFrame

signal plank_added
signal plank_removed
signal window_fortified

var plank_count = 0
var plank_1 = null
var plank_2 = null


func add_plank(plank):
    if plank_count == 0:
        plank_1 = plank
    elif plank_count == 1:
        plank_2 = plank
        plank_1.is_locked = true
        plank_2.is_locked = true
    plank_count = plank_count + 1
    if plank_count >= 2:
        emit_signal("window_fortified")
    else:
        emit_signal("plank_added")

    
func remove_plank(plank):
    if plank_count == 1:
        plank_1 = null
    elif plank_count == 2:
        plank_2 = null
    plank_count = plank_count - 1
    emit_signal("plank_removed")
    
    
func destroy_window(b = null):
    var first_panels = [$DoorPanel, $DoorPanel2, $WindowPanel, $WindowPanel2]
    first_panels.shuffle()
    
    _break_panel(first_panels[0])
    yield(get_tree().create_timer(.2), "timeout")
    _break_panel(first_panels[1])
    yield(get_tree().create_timer(.2), "timeout")
    _break_panel(first_panels[2])
    yield(get_tree().create_timer(.2), "timeout")
    _break_panel(first_panels[3])
    yield(get_tree().create_timer(.2), "timeout")
    
    var first_plank
    var last_plank
    
    if plank_1.global_transform.origin.y > plank_2.global_transform.origin.y:
        first_plank = plank_1
        last_plank = plank_2
    else:
        first_plank = plank_2
        last_plank = plank_1
        
    first_plank.mode = RigidBody.MODE_RIGID
    first_plank.gravity_scale = -.5
    first_plank.get_node("RemovePlayer").play()

    yield(get_tree().create_timer(.5), "timeout")
    
    last_plank.mode = RigidBody.MODE_RIGID
    last_plank.gravity_scale = -.5
    last_plank.get_node("RemovePlayer").play()
    
    yield(get_tree().create_timer(.2), "timeout")
    
    var last_panels = [$WoodPanel, $WoodPanel2]
    last_panels.shuffle()
    _break_panel(last_panels[0])
    yield(get_tree().create_timer(.2), "timeout")
    _break_panel(last_panels[1])
