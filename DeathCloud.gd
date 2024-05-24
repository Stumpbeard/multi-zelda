extends AnimatedSprite

func _ready():
	play()


func _on_DeathCloud_animation_finished():
	queue_free()
