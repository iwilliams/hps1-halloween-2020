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
