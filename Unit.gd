class_name Unit
extends KinematicBody2D

export var speed = 32.0

enum State { spawning, ready, attacking, despawned }
var state = State.ready

onready var origin = global_position
	
func spawn():
	state = State.ready
	$CollisionShape2D.disabled = false
	global_position = origin

func attack():
	pass

func move(direction):
	if state != State.ready:
		return
	if direction == Vector2.ZERO:
		$AnimatedSprite.stop()
	
	if direction.y > 0:
		$AnimatedSprite.play("forward")
	elif direction.y < 0:
		$AnimatedSprite.play("back")

	if direction.x > 0:
		$AnimatedSprite.play("right")
	elif direction.x < 0:
		$AnimatedSprite.play("left")
		
	var _slide = move_and_slide(direction * speed)

func _on_HitBox_area_entered(area):
	if area.is_in_group("projectiles"):
		area.queue_free()
	die()
	
func die():
	var cloud = load("res://DeathCloud.tscn").instance()
	cloud.position = self.position
	get_parent().add_child_below_node(self, cloud)
	state = State.despawned
	$CollisionShape2D.set_deferred("disabled", true)
	global_position = Vector2(-50000, -50000)
