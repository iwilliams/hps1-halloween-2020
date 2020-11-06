extends Grabbalbe

onready var nail = get_node("Nail")
onready var nail_2 = get_node("Nail2")

var nail_area = null
var nail_2_area = null

var is_nailed = false

func _ready():
    nail.connect("area_entered", self, "nail_area_entered", [nail])
    nail.connect("area_exited", self, "nail_area_exited", [nail])
    
    nail_2.connect("area_entered", self, "nail_area_entered", [nail_2])
    nail_2.connect("area_exited", self, "nail_area_exited", [nail_2])
    

func nail_area_entered(area: Area, nail_in: Area):
    if area.name == "NailArea" || area.name == "NailArea2":
        if nail_in == nail:
            nail_area = area
        else:
            nail_2_area = area
        

func nail_area_exited(area: Area, nail_in: Area):
    if area.name == "NailArea" || area.name == "NailArea2":
        if nail_in == nail:
            nail_area = null
        else:
            nail_2_area = null


func _physics_process(delta):
    var nail_threshold = .97
    if nail_area != null:
        var diff = nail_area.global_transform.basis.z.dot(nail.global_transform.basis.z)
        nail.get_child(1).visible = abs(diff) > nail_threshold
    else:
        nail.get_child(1).visible = false

    if nail_2_area != null:
        var diff = nail_2_area.global_transform.basis.z.dot(nail_2.global_transform.basis.z)
        nail_2.get_child(1).visible = abs(diff) > nail_threshold
    else:
        nail_2.get_child(1).visible = false


func can_weld():
    return nail_area != null and nail_2_area != null and nail_area != nail_2_area


func grab():
    if is_nailed:
        $RemovePlayer.play()
        is_nailed = false


func nail():
    is_nailed = true
    $HammerPlayer.play()
