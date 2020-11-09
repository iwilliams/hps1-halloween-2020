extends Grabbalbe

export(bool) var is_locked = false

signal grab_attempted

func _ready():
    if is_locked:
        mode = RigidBody.MODE_STATIC


func can_grab():
    if is_locked:
        emit_signal("grab_attempted")
    return !is_locked


func unlock():
    is_locked = false
    mode = RigidBody.MODE_RIGID


func slam_open():
    apply_central_impulse(global_transform.basis.z.normalized() * 2)
    $SlamPlayer.play()
