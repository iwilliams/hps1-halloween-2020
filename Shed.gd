extends Spatial

var break_count = 0


func break_shed():
    
    if break_count == 0:
        $AnimationPlayer.play("Break1")
    elif break_count == 1:
        $AnimationPlayer.play("Break2")
    elif break_count == 2:
        $AnimationPlayer.play("Break3")
    break_count += 1
