extends RigidBody

onready var body = get_node("../")
onready var pitch = get_node("../Yaw/Pitch")

func _ready():
    $RayCast.add_exception(body)


#func _physics_process(delta):     
#    if body.is_on_floor:
#        axis_lock_linear_y = true
#    else:
#        axis_lock_linear_y = false


func _integrate_forces(state):
    state.transform = pitch.global_transform
    print("lel")
