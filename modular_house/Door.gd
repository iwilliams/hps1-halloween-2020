extends Grabbalbe

export(bool) var is_locked = false


func _ready():
    if is_locked:
        mode = RigidBody.MODE_STATIC


func can_grab():
    return !is_locked


func unlock():
    is_locked = false
    mode = RigidBody.MODE_RIGID
