extends Spatial

var body_to_move : KinematicBody = null

export var move_accel = 4
export var max_speed = 25
var drag = 0.0
export var jump_force = 30
#export var gravity = 60

var pressed_jump = false
var move_vec : Vector3
var velocity : Vector3
var snap_vec : Vector3
export var ignore_rotation = false
#######
export var walking_speed = 4
var gravity = -50
var sensitivity = Vector2(.6, .6)
export var acceleration = 80.0

signal movement_info

var frozen = false

func _ready():
    drag = float(move_accel) / max_speed

func init(_body_to_move: KinematicBody):
    body_to_move = _body_to_move

func jump():
    pressed_jump = true

func set_move_vec(_move_vec: Vector3):
    move_vec = _move_vec.normalized()
    
    
func _physics_process(delta):
    if frozen:
        return
    var cur_move_vec = move_vec
    if !ignore_rotation:
        cur_move_vec = cur_move_vec.rotated(Vector3.UP, body_to_move.rotation.y)
        
    var dir = cur_move_vec * walking_speed
    
    velocity = velocity.move_toward(Vector3(dir.x, velocity.y, dir.z), acceleration*delta)
    
#    velocity += gravity * delta
    velocity = body_to_move.move_and_slide_with_snap(velocity, snap_vec, Vector3.UP, true)
        
    var is_grounded = body_to_move.is_on_floor()
    
    if !is_grounded:
        velocity.y += gravity * delta
        snap_vec = Vector3.ZERO
    else:
        snap_vec = Vector3.DOWN #* .2
        velocity.y += -10 * delta
        

func freeze():
    frozen = true

func unfreeze():
    frozen = false
