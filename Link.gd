class_name Link
extends Unit

func _ready():
	spawn()
	
func spawn():
	global_position = Vector2(origin)
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
	elif direction.y < 0:
		$SwordCollision.rotation_degrees = 180
	if direction.x > 0:
		$SwordCollision.rotation_degrees = -90
	elif direction.x < 0:
		$SwordCollision.rotation_degrees = 90
		
func die():
	.die()
	$RespawnTimer.start(3.0)


func _on_RespawnTimer_timeout():
	spawn()

func serialized():
	return {
		"x": position.x,
		"y": position.y,
		"animation": $AnimatedSprite.animation,
		"playing": $AnimatedSprite.playing,
		"state": state,
		"sword_disabled": $SwordCollision/CollisionShape2D.disabled,
		"sword_rotation": $SwordCollision.rotation_degrees
	}
	
remote func sync_data(data):
	position.x = data.get("x", 0)
	position.y = data.get("y", 0)
	$AnimatedSprite.animation = data.get("animation", "forward")
	$AnimatedSprite.playing = data.get("playing", true)
	state = data.get("state", State.ready)
	$SwordCollision/CollisionShape2D.disabled = data.get("sword_disabled", true)
	$SwordCollision.rotation_degrees = data.get("sword_rotation", 0)
