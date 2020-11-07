extends Spatial


var window_progress = 0

var pd5_has_played = false
var pd6_has_played = false
var pd8_has_played = false
var pd9_has_played = false
var pd11_has_played = false


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


func _window_frame_plank_added(window_frame: WindowFrame):
    if !pd5_has_played:
        $Dialog/pd05.play()
        pd5_has_played = true
    if window_progress == 4 and !pd9_has_played:
        $DoorPlank.is_locked = false
        $Dialog/pd09.play()
        pd9_has_played = true
        yield(get_tree().create_timer(5.0), "timeout")
        $Dialog/pd10.play()
        

func _window_frame_plank_removed(window_frame: WindowFrame):
    $Dialog/pd07.play()


func _window_frame_window_fortified(window_frame: WindowFrame):
    if !pd6_has_played:
        $Dialog/pd06.play()
        pd5_has_played = true
    window_progress = window_progress + 1


func _room_trigger_body_entered(body: PhysicsBody):
    if !pd11_has_played:
        pd11_has_played = true
        $Dialog/pd11.play()


func _door_plank_grab_attempted():
    if !pd8_has_played and window_progress < 4:
        $Dialog/pd08.play()
        pd8_has_played = true
        yield($Dialog/pd08, "finished")
        pd8_has_played = false
