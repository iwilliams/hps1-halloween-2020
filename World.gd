extends Spatial


signal game_ended

var window_progress = 0

var pd4_has_played = false
var pd5_has_played = false
var pd6_has_played = false
var pd8_has_played = false
var pd9_has_played = false
var pd10_a_has_played = false
var pd11_has_played = false
var pd12_has_played = false
var pd13_has_played = false

export(bool) var should_hide_body = false


func _ready():
    var screen_size = OS.get_screen_size(0)
    var window_size = OS.get_window_size()
    OS.set_window_position(screen_size*0.5 - window_size*0.5)
    
    randomize()
    
    $Player/Body/Yaw/Pitch/Camera2.trauma = 0
    
    var window_frames = get_tree().get_nodes_in_group("Window")
    for f in window_frames:
        var window_frame = f as WindowFrame
        window_frame.connect("plank_added", self, "_window_frame_plank_added", [window_frame])
        window_frame.connect("plank_removed", self, "_window_frame_plank_removed", [window_frame])
        window_frame.connect("window_fortified", self, "_window_frame_window_fortified", [window_frame])
    
    $RoomTrigger.connect("body_entered", self, "_room_trigger_body_entered")
    $DoorPlank.connect("grab_attempted", self, "_door_plank_grab_attempted")
    $CoffinPlank1.connect("grabbed", self, "_coffin_plank_grabbed", [], CONNECT_ONESHOT)
    $CoffinPlank2.connect("grabbed", self, "_coffin_plank_grabbed", [], CONNECT_ONESHOT)


func _start_finale():
    $DoorPlank.is_locked = false
    $Dialog/pd09.play()
    pd9_has_played = true
    yield($Dialog/pd09, "finished")
    $Dialog/pd10.play()


func _window_frame_plank_added(window_frame: WindowFrame):       
    window_progress += .5
    
    if window_progress == 4.5 and !pd9_has_played:
        _start_finale()
    elif window_progress == 4 && !pd4_has_played:
        $SirenPlayer.play()
        pd4_has_played = true
        yield(get_tree().create_timer(1), "timeout")
        $Dialog/pd04.play()
    elif !pd5_has_played and window_progress < 5:
        var possible_players = [$Dialog/pd05, $Dialog/pd05_alt]
        possible_players.shuffle()
        possible_players[0].play()
        pd5_has_played = true
        yield(possible_players[0], "finished")
        pd5_has_played = false


func _window_frame_plank_removed(window_frame: WindowFrame):
    window_progress -= .5
    var p = [$Dialog/pd07, $Dialog/pd07_alt]
    p.shuffle()
    p[0].play()


func _window_frame_window_fortified(window_frame: WindowFrame):
    window_progress += .5
    
    if window_progress == 5:
        $Dialog/pd10_b.play()
        $House/DoorFrame2/Door.unlock()
    elif window_progress == 4.5 and !pd9_has_played:
        _start_finale()
    elif window_progress == 4 && !pd4_has_played:
        $SirenPlayer.play()
        pd4_has_played = true
        yield(get_tree().create_timer(.2), "timeout")
        $Dialog/pd04.play()
    elif !pd6_has_played and window_progress < 6:
        var possible_players = [$Dialog/pd06, $Dialog/pd06_alt]
        possible_players.shuffle()
        possible_players[0].play()
        pd6_has_played = true
        yield(possible_players[0], "finished")
        pd6_has_played = false


func open_bedroom_door_attempt():
    if window_progress == 4.5 and !pd10_a_has_played and $DoorPlank.is_nailed == false:
        $Dialog/pd10_a.play()
        pd10_a_has_played = true
        yield($Dialog/pd10_a, "finished")
        pd10_a_has_played = false  


func _room_trigger_body_entered(body: PhysicsBody):
    if !pd11_has_played:
        pd11_has_played = true
        $Dialog/pd11.play()
        $HeavyWindPlayer.play()
        $HeavyWindPlayer/Tween.interpolate_property($HeavyWindPlayer, 'volume_db', -80, -8, 15)
        $HeavyWindPlayer/Tween.interpolate_property($Player/Body/Yaw/Pitch/Camera2, 'trauma', 0, .2, 15)
        $HeavyWindPlayer/Tween.start()
        $House/WindowFrame/StaticBody.queue_free()


func _door_plank_grab_attempted():
    if !pd8_has_played and window_progress < 5:
        $Dialog/pd08.play()
        pd8_has_played = true
        yield($Dialog/pd08, "finished")
        pd8_has_played = false


func _coffin_plank_grabbed():
    if !pd12_has_played:
        $Dialog/pd12.play()
        pd12_has_played = true
    elif !pd13_has_played:
        $Dialog/pd13.play()
        pd13_has_played = true
        

func destroy_props():
    var props = [$Sofa, $Tv, $EntranceTable, $Chair, $Sink, $Chair2, $Table, $BedFrame, $Storage/Shelves, $Storage/Shelves2]
    for prop in props:
        prop.mode = RigidBody.MODE_RIGID
        prop.gravity_scale = -.5
        prop.apply_torque_impulse(Vector3(0, .2, 0))
        yield(get_tree().create_timer(.2), "timeout")


func thunder_check():
    if should_hide_body:
        $Coffin/body.visible = false
