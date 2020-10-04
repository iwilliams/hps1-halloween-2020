extends RigidBody

onready var body = get_node("../Body")
onready var pitch = get_node("../Body/Yaw/Pitch")

func _ready():
    $RayCast.add_exception(body)


#func _physics_process(delta):     
#    if body.is_on_floor:
#        axis_lock_linear_y = true
#    else:
#        axis_lock_linear_y = false


#func _integrate_forces(state):
#    var current_transform = state.transform
#    var target_transform = Transform(pitch.global_transform.basis, pitch.global_transform.origin)
#    state.set_transform(target_transform)
