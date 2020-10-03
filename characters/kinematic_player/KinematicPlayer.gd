extends KinematicBody

export var mouse_sens := 0.5
export var stick_sens := 2.0
export var is_inverted = true

onready var camera : Camera = $Camera
onready var character_mover = $CharacterMover

var mouse_movement = Vector2()

export(NodePath) var holding_path
onready var holding = get_node(holding_path)
var col_shape

func _ready():
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    character_mover.init(self)
    
    if holding:
        col_shape = CollisionShape.new()
        var holding_col_shape = holding.get_node("CollisionShape")
        col_shape.shape = holding_col_shape.shape
        add_child(col_shape)
        col_shape.global_transform = holding_col_shape.global_transform
    

func _physics_process(delta):
    if holding:
        var holding_col_shape = holding.get_node("CollisionShape")
        col_shape.global_transform = holding_col_shape.global_transform
        
        
    rotation_degrees.y -= mouse_sens * mouse_movement.x
    var col = move_and_collide(Vector3.ZERO, true, true, true)
    if col:
        rotation_degrees.y += mouse_sens * mouse_movement.x
    camera.rotation_degrees.x -= mouse_sens * mouse_movement.y
    camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90, 90)
    mouse_movement = Vector2()


func _process(_delta):

    if Input.is_action_just_pressed("ui_cancel"):
        if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
            Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
        else:
            Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
                
    var move_vec = Vector3()
    if Input.is_action_pressed("move_forward"):
        move_vec += Vector3.FORWARD
    if Input.is_action_pressed("move_backward"):
        move_vec += Vector3.BACK
    if Input.is_action_pressed("move_left"):
        move_vec += Vector3.LEFT
    if Input.is_action_pressed("move_right"):
        move_vec += Vector3.RIGHT
    character_mover.set_move_vec(move_vec)
    if Input.is_action_just_pressed("jump"):
        character_mover.jump()
        
    if Input.is_action_pressed("look_left") or Input.is_action_pressed("look_right"):
        rotation_degrees.y += (Input.get_action_strength("look_left") - Input.get_action_strength("look_right")) * stick_sens
    
    if Input.is_action_pressed("look_up") or Input.is_action_pressed("look_down"):
        var x_delta = (Input.get_action_strength("look_up") - Input.get_action_strength("look_down")) * stick_sens
        if is_inverted:
            x_delta *= -1
        camera.rotation_degrees.x += x_delta
        camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90, 90)


func _input(event):
    if event is InputEventMouseMotion && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
        mouse_movement = event.relative
#        rotation_degrees.y -= mouse_sens * event.relative.x
#        var col = move_and_collide(Vector3.ZERO, true, true, true)
#        if col:
#            rotation_degrees.y += mouse_sens * event.relative.x
#        camera.rotation_degrees.x -= mouse_sens * event.relative.y
#        camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90, 90)
