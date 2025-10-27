extends MeshInstance3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var mat
	if([true,false].pick_random()): mat = load("res://Mats/WorldMaterial.tres")
	else: 
		mat = load("res://Mats/SkyMaterial.tres")
		#if([true,false].pick_random()):
		#	position.y+=randf_range(0.8,2)
	set_surface_override_material(0,mat)
