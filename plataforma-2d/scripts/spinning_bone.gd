extends Area2D

var speed = 85
@export var direction = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += delta * speed * direction

func set_direction(skeleton_direction):
	self.direction = skeleton_direction
	scale.x = direction
