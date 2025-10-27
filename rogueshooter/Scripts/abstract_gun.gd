extends Node3D
class_name Gun

@export var gunToLoadName:String=""
@export var rotLerpRate:float
@export var multiShot:int=1
var curRotLerp:float
var aimOffset:Vector3
@export var aimRecoverySpeed:float
@export var posLerpRate:float
@export var kickAngleHigh:Vector2
@export var kickAngleLow:Vector2
var myRot:Quaternion
var headRot:Quaternion
@onready var crosshairRay:RayCast3D = $CrossHairRay
@onready var crosshairSprite:Sprite3D = $CrosshairSprite
@onready var muzzleFlashOmniLight:OmniLight3D=$OffsetNode/MuzzFlashLight
@onready var gunModel:MeshInstance3D=$OffsetNode/GunMdl

@onready var offsetNode:Node3D=$OffsetNode
@onready var reloadNode:Node3D=$ReloadPos

@export var spread:Vector2 #1 is the highest value you should use
var firing:bool = false
@export var semiAuto:bool
@export var fireRate:float
var fireTimer:float=0
@export var fireObjName:String
#@onready var fireObj =load("res://Projectiles/"+fireObjName+".tscn")
var fireObj
# sets properties of projectile
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
var currAmmo:int=0
@export var reloadStageCount:int=2
var currReloadStage:int=0
var isReloading:bool=false
@export var reloadStageTotalLength:float=2
var timeLeftInStage:float=0
var perfectReloadPoint:float=0

static var staticInstance:Gun

func _init() -> void:
	staticInstance=self

func _ready() -> void:
	if(reloadStageCount<1):reloadStageCount=1
	currAmmo=ammoCount
	if(gunToLoadName!=""):
		var gunData=load("res://GunDataSetScenes/"+gunToLoadName)
		add_child(gunData.instantiate())
	fireObj=load("res://PlayerProjectiles/"+fireObjName+".tscn")
	curRotLerp=rotLerpRate
	#just in case I screw up it'll fix the kick angle
	if(kickAngleLow.x>kickAngleHigh.x): kickAngleLow.x=kickAngleHigh.x
	if(kickAngleLow.y>kickAngleHigh.y): kickAngleLow.y=kickAngleHigh.y
	

func _process(delta: float) -> void:
	if(isReloading):
		#causes the gun to smooth between reload pos and current pos
		gunModel.global_position= gunModel.global_position.lerp(lerp(offsetNode.global_position,
		reloadNode.global_position,timeLeftInStage/(reloadStageTotalLength/reloadStageCount)),0.5)
		gunModel.global_basis=Basis(gunModel.global_basis.get_rotation_quaternion().slerp(
			lerp(offsetNode.global_basis.get_rotation_quaternion(),
				reloadNode.global_basis.get_rotation_quaternion(),
				timeLeftInStage/(reloadStageTotalLength/reloadStageCount))
		,0.5))
		# gunModel.global_basis.slerp(lerp(offsetNode.global_basis,
		#reloadNode.global_basis,timeLeftInStage/(reloadStageTotalLength/reloadStageCount)),0.5)
		if(timeLeftInStage>0):#time down til next stage
			timeLeftInStage-=delta
		elif(currReloadStage>1):#progress stage
			timeLeftInStage=reloadStageTotalLength/reloadStageCount
			currReloadStage-=1
			print_debug("RELOADING stage reduced was "+str(currReloadStage+1)+", now "+str(currReloadStage))
		else: #end reload
			print_debug("RELOADING end")
			#Player.staticInstance.viewPCam.fov=90
			gunModel.position=Vector3.ZERO
			gunModel.rotation=Vector3.ZERO
			gunModel.basis=basis.from_euler(Vector3.ZERO)
			if(ammoPerReload<1): currAmmo=ammoCount
			else: currAmmo=clampi(currAmmo+ammoPerReload,0,ammoCount)
			isReloading=false
	
	if(crosshairRay.is_colliding()):
		crosshairSprite.global_position=crosshairRay.get_collision_point()
	else:
		crosshairSprite.global_position=global_position+(-global_basis.z*3)
		
	if(fireTimer>0):
		fireTimer-=delta
	elif(firing): 
		if(semiAuto): firing=false
		fireGun()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	#muzzleflash handling
	if(muzzleFlashOmniLight.light_energy>0):
		muzzleFlashOmniLight.light_energy=lerpf(muzzleFlashOmniLight.light_energy,0, muzzleDarkLerp)
	if(muzzleFlashOmniLight.light_indirect_energy>0):
		muzzleFlashOmniLight.light_indirect_energy=lerpf(muzzleFlashOmniLight.light_indirect_energy,0, muzzleDarkLerp)
	if(muzzleFlashOmniLight.light_volumetric_fog_energy>0):
		muzzleFlashOmniLight.light_volumetric_fog_energy=lerpf(muzzleFlashOmniLight.light_volumetric_fog_energy,0, muzzleDarkLerp)
	#move to player position/rotation
	if(curRotLerp!=rotLerpRate):
		curRotLerp=lerpf(curRotLerp,rotLerpRate,aimRecoverySpeed)#aim recovery speed.
	if(aimOffset!=Vector3.ZERO):aimOffset=aimOffset.lerp(Vector3.ZERO,aimRecoverySpeed)
	global_position=global_position.lerp(Player.staticInstance.neckNode.global_position,posLerpRate)
	#rotation
	myRot=global_basis.get_rotation_quaternion()
	headRot=Player.staticInstance.fpsCamera.global_basis.get_rotation_quaternion()
	global_basis = Basis(myRot.slerp(headRot,curRotLerp))
	rotation+=aimOffset*delta#scales down the incredibly high speed of recoil

func gunShot():
	var localInst = fireObj.instantiate()
	localInst.position = global_position
	localInst.rotation = global_rotation
	localInst.rotation.x += randf_range(-spread.y,spread.y)
	localInst.rotation.y += randf_range(-spread.x,spread.x)
	if(localInst is hitscanAttack):
		localInst.damage=damage
		localInst.distance=distance
		localInst.falloffRate=falloffRate
		localInst.knockBack=knockBack
		localInst.hitsPlayer=false
	sceneOriginManager.staticInst.add_child(localInst)

func reload():
	print_debug("RELOAD pressed")
	if(!isReloading and currAmmo<ammoCount):
		#Player.staticInstance.viewPCam.fov=120
		print_debug("RELOAD start")
		isReloading=true
		currReloadStage=reloadStageCount
		var rLen:float = reloadStageTotalLength/reloadStageCount
		timeLeftInStage=rLen
		perfectReloadPoint=randf_range(rLen*0.25,rLen*0.75)
	elif(isReloading and timeLeftInStage>0 and
	 (timeLeftInStage>perfectReloadPoint-0.15 and timeLeftInStage<perfectReloadPoint+0.15)):
		print_debug("PERFECT RELOAD!!!")
		timeLeftInStage=0

func fireGun():
	if !(Player.staticInstance.jumpTime>0 or isReloading or currAmmo<=0):
		if(currAmmo>0):currAmmo-=1
		print_debug("FIRED; currAmmo="+str(currAmmo)) 
		# prevents firing whilst invulnerable or whilst reloading
		muzzleFlashOmniLight.light_energy=muzzleFlashEnergy
		muzzleFlashOmniLight.light_indirect_energy=muzzleFlashIndrEnergy
		muzzleFlashOmniLight.light_volumetric_fog_energy=muzzleVolFog
		fireTimer=fireRate #fire timer set here
		for i in range(multiShot): gunShot()
		#Recoil segment below
		aimOffset.x+=randf_range(kickAngleLow.x,kickAngleHigh.x)
		aimOffset.y+=randf_range(kickAngleLow.y,kickAngleHigh.y)
	else:
		print_debug("CANNOT FIRE")
		pass #TODO play click noise
	
func _unhandled_input(event: InputEvent) -> void:
	if(event.is_action_pressed("Reload")):
		reload()
	if(event.is_action_pressed("Shoot")):
		firing=true
	if(event.is_action_released("Shoot")):#it's like this so semi auto firing works
		firing=false
	#dummy comment
