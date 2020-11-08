extends Frame


func _ready():
    var exceptions = [$Stairs, $WoodPanel, $WoodPanel2, $DoorPanel, $DoorPanel2, $FrameTop, $FrameLeft, $FrameRight, $FrameLeftMiddle, $FrameRightMiddle]
    for excep in exceptions: 
        $Door.add_collision_exception_with(excep)


func unlock():
    $Door.unlock()


func destroy_door():
    pass
