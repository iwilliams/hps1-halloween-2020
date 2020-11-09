extends Spatial


var window_progress = 0

var pd5_has_played = false
var pd6_has_played = false
var pd8_has_played = false
var pd9_has_played = false
var pd11_has_played = false
var pd12_has_played = false
var pd13_has_played = false

func _ready():
    var screen_size = OS.get_screen_size(0)
    var window_size = OS.get_window_size()
    OS.set_window_position(screen_size*0.5 - window_size*0.5)
    
    randomize()
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
    yield(get_tree().create_timer(5.0), "timeout")
    $Dialog/pd10.play()


func _window_frame_plank_added(window_frame: WindowFrame):
    if !pd5_has_played:
        $Dialog/pd05.play()
        pd5_has_played = true
    if window_progress == 4 and !pd9_has_played:
        _start_finale()
 

func _window_frame_plank_removed(window_frame: WindowFrame):
    $Dialog/pd07.play()


func _window_frame_window_fortified(window_frame: WindowFrame):
    window_progress = window_progress + 1
    if window_progress == 4 and !pd9_has_played:
        _start_finale()
    elif !pd6_has_played and window_progress < 6:
        $Dialog/pd06.play()
        pd5_has_played = true


func _room_trigger_body_entered(body: PhysicsBody):
    if !pd11_has_played:
        pd11_has_played = true
        $Dialog/pd11.play()
        $HeavyWindPlayer.play()
        $HeavyWindPlayer/Tween.interpolate_property($HeavyWindPlayer, 'volume_db', -80, 1, 15)
        $HeavyWindPlayer/Tween.start()


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
    var props = [$Sofa, $Tv, $EntranceTable, $Chair, $Sink, $Chair2, $Table, $BedFrame]
    for prop in props:
        prop.mode = RigidBody.MODE_RIGID
        prop.gravity_scale = -.5
        prop.apply_torque_impulse(Vector3(0, .2, 0))
        yield(get_tree().create_timer(.2), "timeout")
