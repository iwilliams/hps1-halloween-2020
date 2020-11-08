extends Area



func _on_CleanUpTrigger_body_entered(body: PhysicsBody):
    body.queue_free()
    print("Clean up")
