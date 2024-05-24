class_name Oktorok
extends Unit

var wander_direction = Vector2()

func _ready():
	spawn()

func spawn():
	global_position = origin
	var current_facing = $AnimatedSprite.animation
	state = State.spawning
	$AnimatedSprite.play("spawn")
	yield($AnimatedSprite, "animation_finished")
	.spawn()
	$AnimatedSprite.play(current_facing)
	$DecisionTimer.start(0.0)

func die():
	.die()
	$RespawnTimer.start(3.0)

func _on_RespawnTimer_timeout():
	spawn()

remotesync func shoot_rock():
	var rock = load("res://Rock.tscn").instance()
	get_parent().add_child_below_node(self, rock, true)
	rock.position = position
	var dir = Vector2()
	match $AnimatedSprite.animation:
		"forward":
			dir.y += 1
		"back":
			dir.y -= 1
		"left":
			dir.x -= 1
		"right":
			dir.x += 1
			
	rock.position += dir * 8
	rock.travel_direction = dir

func ai():
	if state != State.ready:
		return
	if is_zero_approx($DecisionTimer.time_left):
		var decision = randi() % 4
		match decision:
			0:
				decision = 1
				continue
			1:
				wander_direction = Vector2()
				wander_direction.x = randi() % 3 - 1
				if is_zero_approx(wander_direction.x):
					wander_direction.y = randi() % 3 - 1
				wander_direction = wander_direction.normalized()
			2:
				wander_direction = Vector2()
			3:
				rpc("shoot_rock")
		$DecisionTimer.start(1.0)
	move(wander_direction)
