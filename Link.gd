class_name Link
extends Unit

func _ready():
	spawn()
	
func spawn():
	global_position = origin
	state = State.spawning
	var tween = create_tween()
	tween.set_loops(5)
	tween.tween_property($AnimatedSprite, "modulate:a", 0.0, 0.05)
	tween.tween_property($AnimatedSprite, "modulate:a", 1.0, 0.05)
	yield(tween, "finished")
	.spawn()

func attack():
	if state != State.ready:
		return
	state = State.attacking
	$SwordCollision/CollisionShape2D.disabled = false
	var current_facing = $AnimatedSprite.animation
	$AnimatedSprite.play("%s_attack" % [current_facing])
	yield($AnimatedSprite, "animation_finished")
	$SwordCollision/CollisionShape2D.disabled = true
	$AnimatedSprite.play(current_facing)
	$AnimatedSprite.stop()
	state = State.ready

func move(direction):
	if state != State.ready:
		return
	.move(direction)

	if direction.y > 0:
		$SwordCollision.rotation_degrees = 0
		$SwordCollision.position = Vector2()
	elif direction.y < 0:
		$SwordCollision.rotation_degrees = 180
		$SwordCollision.position = Vector2(-1, -1)
	if direction.x > 0:
		$SwordCollision.rotation_degrees = -90
		$SwordCollision.position = Vector2(0, 2)
	elif direction.x < 0:
		$SwordCollision.rotation_degrees = 90
		$SwordCollision.position = Vector2(0, 2)
		
	var collision = get_last_slide_collision()
	if collision && collision.collider.is_in_group("enemies"):
		die()
		
func die():
	.die()
	$RespawnTimer.start(3.0)


func _on_RespawnTimer_timeout():
	spawn()
