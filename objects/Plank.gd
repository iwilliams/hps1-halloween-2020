extends Grabbalbe

onready var nail = get_node("Nail")
onready var nail_2 = get_node("Nail2")

func _ready():
    nail.connect("area_entered", self, "nail_area_entered", [nail])
    nail.connect("area_exited", self, "nail_area_exited", [nail])
    
    nail_2.connect("area_entered", self, "nail_area_entered", [nail_2])
    nail_2.connect("area_exited", self, "nail_area_exited", [nail_2])
    

func nail_area_entered(area: Area, nail: Area):
    if area.name == "NailArea" || area.name == "NailArea2":
        nail.get_child(1).visible = true
        

func nail_area_exited(area: Area, nail: Area):
    if area.name == "NailArea" || area.name == "NailArea2":
        nail.get_child(1).visible = false
