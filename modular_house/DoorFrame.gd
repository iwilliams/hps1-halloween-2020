extends Frame


func _ready():
    var exceptions = [$Stairs, $WoodPanel, $WoodPanel2, $DoorPanel, $DoorPanel2, $FrameTop, $FrameLeft, $FrameRight, $FrameLeftMiddle, $FrameRightMiddle]
    for excep in exceptions: 
        $Door.add_collision_exception_with(excep)


func unlock():
    $Door.unlock()


func destroy_door(b = null):
    for i in range(0, 4 - break_count):
        break_wall()
        yield(get_tree().create_timer(1), "timeout")

    $FrameTop.mode = RigidBody.MODE_RIGID
    $FrameTop.apply_torque_impulse(Vector3(0, .2, 0))

    yield(get_tree().create_timer(.2), "timeout")
    $FrameLeft.mode = RigidBody.MODE_RIGID
    $FrameLeft.apply_torque_impulse(Vector3(0, 0, .2))
    
    yield(get_tree().create_timer(.2), "timeout")
    $FrameRight.mode = RigidBody.MODE_RIGID
    $FrameRight.apply_torque_impulse(Vector3(0, 0, -.2))
    
    yield(get_tree().create_timer(.2), "timeout")
    $FrameRightMiddle.mode = RigidBody.MODE_RIGID
    $FrameRightMiddle.apply_torque_impulse(Vector3(0, 0, -.2))
    
    yield(get_tree().create_timer(.2), "timeout")
    $FrameLeftMiddle.mode = RigidBody.MODE_RIGID
    $FrameLeftMiddle.apply_torque_impulse(Vector3(0, 0, -.2))
    
    yield(get_tree().create_timer(.2), "timeout")
    $Door/HingeJoint.queue_free()
    $Door.mode = RigidBody.MODE_RIGID
    $Door.gravity_scale = -.5
    $Door.apply_torque_impulse(Vector3(0, 0, -.2))
