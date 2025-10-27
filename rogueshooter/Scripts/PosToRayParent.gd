extends Node3D

@export var parentRay:RayCast3D
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(parentRay.is_colliding()):
		global_position=parentRay.get_collision_point()
	else: global_position=parentRay.global_position
