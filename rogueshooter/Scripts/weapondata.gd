extends Node

class_name weaponDataSet

@export var rotLerpRate:float
@export var multiShot:int=1
@export var aimRecoverySpeed:float
@export var posLerpRate:float
@export var kickAngleHigh:Vector2
@export var kickAngleLow:Vector2
@export var spread:Vector2 #1 is the highest value you should use
@export var semiAuto:bool
@export var fireRate:float
@export var fireObjName:String
@export var damage:int=1
@export var distance:float=100
@export var falloffRate:float=0.1
@export var knockBack:float=2
@export var muzzleFlashEnergy:float=3
@export var muzzleFlashIndrEnergy:float=6
@export var muzzleVolFog:float=0.5
@export var muzzleDarkLerp:float=0.5
@export var ammoCount:int=10
@export var ammoPerReload:int=0
@export var reloadStageCount:int=2
@export var reloadStageTotalLength:float=2
@export var gunMesh:ArrayMesh
@export var gunMaterial:Array[StandardMaterial3D]

func _ready() -> void:
	loadToWep()

func loadToWep():
	Gun.staticInstance.rotLerpRate=rotLerpRate
	Gun.staticInstance.multiShot=multiShot
	Gun.staticInstance.aimRecoverySpeed=aimRecoverySpeed
	Gun.staticInstance.posLerpRate=posLerpRate
	Gun.staticInstance.kickAngleHigh=kickAngleHigh
	Gun.staticInstance.kickAngleLow=kickAngleLow
	Gun.staticInstance.spread=spread #1 is the highest value you should use
	Gun.staticInstance.semiAuto=semiAuto
	Gun.staticInstance.fireRate=fireRate
	Gun.staticInstance.fireObjName=fireObjName
	Gun.staticInstance.damage=damage
	Gun.staticInstance.distance=distance
	Gun.staticInstance.falloffRate=falloffRate
	Gun.staticInstance.knockBack=knockBack
	Gun.staticInstance.muzzleFlashEnergy=muzzleFlashEnergy
	Gun.staticInstance.muzzleFlashIndrEnergy=muzzleFlashIndrEnergy
	Gun.staticInstance.muzzleVolFog=muzzleVolFog
	Gun.staticInstance.muzzleDarkLerp=muzzleDarkLerp
	Gun.staticInstance.ammoCount=ammoCount
	Gun.staticInstance.ammoPerReload=ammoPerReload
	Gun.staticInstance.reloadStageCount=reloadStageCount
	Gun.staticInstance.reloadStageTotalLength=reloadStageTotalLength
	#Visual assets.set
	Gun.staticInstance.gunModel.mesh=gunMesh
	for i in range(len(gunMaterial)):
		Gun.staticInstance.gunModel.set_surface_override_material(i,gunMaterial[i])
