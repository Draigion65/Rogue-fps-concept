extends RayCast3D

class_name hitscanAttack

@export var hitsPlayer:bool=true
@export var hitsEnemy:bool=true
@export var damage:int=1
@export var distance:float=100
@export var falloffRate:float=0.1
@export var knockBack:float=2


func _ready() -> void:
	if(!hitsPlayer and !hitsEnemy): hitsEnemy=true
	target_position.z=-distance
	force_update_transform()
	force_raycast_update()
	if(is_colliding()):
		var hitEnt:Node3D = get_collider()
		
		damage = int(roundf(lerp(float(damage),float(damage)*falloffRate,
		(global_position.distance_to(hitEnt.global_position)/distance))))
		#print_debug(hitEnt.name + ": damage dealt "+str(damage)+":")
		if(hitsEnemy and hitEnt is Enemy):
			#print_debug("ENEMY HIT")
			var enem:Enemy = hitEnt
			enem.hurt(damage,knockBack,-global_basis.z)
		if(hitsPlayer and hitEnt is Player):
			#print_debug("PLAYER HIT")
			Player.staticInstance.hurt(damage,knockBack,-global_basis.z)
	else:
		pass
	queue_free()
	
