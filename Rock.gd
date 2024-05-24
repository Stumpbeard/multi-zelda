extends Area2D

var travel_direction = Vector2()
var speed = 64.0

func _physics_process(delta):
	position += travel_direction * speed * delta


func _on_DespawnTimer_timeout():
	queue_free()
