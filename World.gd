extends Spatial


var window_progress = 0

var pd5_has_played = false
var pd6_has_played = false
var pd11_has_played = false


func _ready():
    randomize()
    var window_frames = get_tree().get_nodes_in_group("Window")
    for f in window_frames:
        var window_frame = f as WindowFrame
        window_frame.connect("plank_added", self, "_window_frame_plank_added", [window_frame])
        window_frame.connect("plank_removed", self, "_window_frame_plank_removed", [window_frame])
        window_frame.connect("window_fortified", self, "_window_frame_window_fortified", [window_frame])
    
    $RoomTrigger.connect("body_entered", self, "_room_trigger_body_entered")


func _window_frame_plank_added(window_frame: WindowFrame):
    if !pd5_has_played:
        $Dialog/pd05.play()
        pd5_has_played = true


func _window_frame_plank_removed(window_frame: WindowFrame):
    $Dialog/pd07.play()


func _window_frame_window_fortified(window_frame: WindowFrame):
    if !pd6_has_played:
        $Dialog/pd06.play()
        pd5_has_played = true
    window_progress = window_progress + 1
    print(window_progress)


func _room_trigger_body_entered(body: PhysicsBody):
    if !pd11_has_played:
        pd11_has_played = true
        $Dialog/pd11.play()
