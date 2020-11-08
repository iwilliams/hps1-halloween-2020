extends Spatial


func play():
    var children := get_children()
    children.shuffle()
    children[0].play()
