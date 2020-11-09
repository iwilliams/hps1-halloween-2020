extends Control

var intro_done = false
var game_done = false

func _ready():
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    
    var screen_size = OS.get_screen_size(0)
    var window_size = OS.get_window_size()
    OS.set_window_position(screen_size*0.5 - window_size*0.5)
    
    $VideoPlayer.connect("finished", self, "intro_finished", [], CONNECT_ONESHOT)
    
    
func intro_finished():
    $VideoPlayer.queue_free()
    $ViewportContainer/Viewport/World.replace_by_instance()
    $ViewportContainer/Viewport/World.connect("game_ended", self, "_on_World_game_ended")
    $AnimationPlayer.play("FadeIn")
    intro_done = true


func _process(_delta):
    if Input.is_action_just_pressed("ui_cancel") and intro_done:
        if game_done:
            _on_ExitGame_pressed()
            return
        if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
            Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
            $Pause.visible = true
            get_tree().paused = true
            $Pause/AnimationPlayer.seek(0)
        else:
            Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
            $Pause.visible = false
            get_tree().paused = false


func _on_ExitGame_pressed():
    get_tree().quit()


func _on_FullscrenTogle_pressed():
    OS.window_fullscreen = !OS.window_fullscreen


func _on_World_game_ended():
    game_done = true
    $ViewportContainer/Viewport/World.queue_free()
    $AnimationPlayer.play("End")
