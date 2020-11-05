extends RigidBody


func _ready():
    var z_flip = randi() % 2
    var y_flip = randi() % 2
    get_child(0).rotation_degrees = Vector3(0, z_flip * 180, y_flip * 180)
