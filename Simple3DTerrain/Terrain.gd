extends Spatial

export(float) var rotationSpeed := 30.0

func _process(delta: float) -> void:
	rotation_degrees.y += rotationSpeed * delta
	if rotation_degrees.y >= 360.0:
		rotation_degrees.y = 0
