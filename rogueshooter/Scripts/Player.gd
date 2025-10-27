extends RigidBody3D
class_name Player

@export var headbobScalar:float

@export var moveVecScalar: Vector2
@export var rotVecScalar: Vector2
@export var dragf: float
static var staticInstance: Player
var moveVec: Vector2
var moveVec3d: Vector3
var mouseVec: Vector2
@onready var fpsCamera:Camera3D=$Neck/FPScam
@onready var viewPCam:Camera3D=$UICanvas/SubViewportContainer/SubViewport/GunCam
@onready var neckNode: Node3D =$Neck

@export var jumpDist:float=2
var jumpTime:float=0
@export var jumpTimeMax:float=0.3
var jumpCoolTime:float=0
@export var jumpCooldown:float=0.4
# Called when the node enters the scene tree for the first time.
func _init() -> void:
	staticInstance=$"."
	#print_debug(staticInstance.name + "name")

func _ready() -> void:
	viewPCam.environment=fpsCamera.environment
	viewPCam.fov=90
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	viewPCam.global_transform=fpsCamera.global_transform
	if(jumpCoolTime>0): jumpCoolTime-=delta
	if(jumpTime>0): #the jump/slide
		#print_debug("jumping")
		jumpTime-=delta
		neckNode.position.y= lerp(neckNode.position.y,-jumpTime/jumpTimeMax,0.3) #jump camera anim
	else: # headbob
		neckNode.position.y = (sin(global_position.x)+cos(global_position.z))*headbobScalar
	moveVec =  Vector2(Input.get_axis("Mleft","Mright"),
	Input.get_axis("Mup","Mdown")).normalized() * moveVecScalar
	fpsCamera.rotate_x(mouseVec.y*rotVecScalar.y)
	fpsCamera.rotation.x = clamp(fpsCamera.rotation.x,deg_to_rad(-50),deg_to_rad(50))
	mouseVec=Vector2.ZERO

func _physics_process(delta: float) -> void:
	moveVec3d = (global_basis.x*moveVec.x)+(global_basis.z*moveVec.y)
	linear_velocity+=moveVec3d
	linear_velocity= linear_velocity.lerp(Vector3.ZERO,dragf)
	rotate_y(mouseVec.x*rotVecScalar.x)
	#print_debug(str(moveVec3d)+" inpvec| "+str(linear_velocity)+" linvel")
	
func jumpAction():
	if(jumpTime<=0&&jumpCoolTime<=0):
		linear_velocity+=(global_basis.z*moveVec.y*jumpDist)+(global_basis.x*moveVec.x*jumpDist)
		jumpTime=jumpTimeMax
		jumpCoolTime=jumpCooldown

func _unhandled_input(event: InputEvent) -> void:
	if(event.is_action_pressed("ui_cancel")):
		Input.mouse_mode= Input.MOUSE_MODE_VISIBLE
	elif(event is InputEventMouseButton and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED):
		Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			mouseVec = -event.relative
	if(event.is_action_pressed("Jump")):
		jumpAction()
		
func hurt(damage:int,knockback:float,knockbackAngle:Vector3)->void:
	if(jumpTime>0): #invulnerable while sliding
		pass
	else:
		linear_velocity+=knockbackAngle*knockback
		#TODO make hurt exist
