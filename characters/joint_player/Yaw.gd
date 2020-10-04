extends Spatial

export var mouse_sens := 0.5
export var stick_sens := 2.0
export var is_inverted = false


func _ready():
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _process(_delta):
    if Input.is_action_just_pressed("ui_cancel"):
        if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
            Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
        else:
            Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


    if Input.is_action_pressed("look_left") or Input.is_action_pressed("look_right"):
        rotation_degrees.y += (Input.get_action_strength("look_left") - Input.get_action_strength("look_right")) * stick_sens
    
    if Input.is_action_pressed("look_up") or Input.is_action_pressed("look_down"):
        var x_delta = (Input.get_action_strength("look_up") - Input.get_action_strength("look_down")) * stick_sens
        if is_inverted:
            x_delta *= -1
        $Pitch.rotation_degrees.x += x_delta
        $Pitch.rotation_degrees.x = clamp($Pitch.rotation_degrees.x, -90, 90)


func _input(event):
    if event is InputEventMouseMotion && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
        rotation_degrees.y -= mouse_sens * event.relative.x
        var x_delta = mouse_sens * event.relative.y
        if is_inverted:
            x_delta *= -1
        $Pitch.rotation_degrees.x += x_delta
        $Pitch.rotation_degrees.x = clamp($Pitch.rotation_degrees.x, -90, 90)
