extends Spatial


func _ready():
    $Door.add_collision_exception_with($Stairs)
    $Door.add_collision_exception_with($WoodPanel)
    $Door.add_collision_exception_with($WoodPanel2)
    $Door.add_collision_exception_with($DoorPanel)
    $Door.add_collision_exception_with($DoorPanel2)


func unlock():
    $Door.unlock()
