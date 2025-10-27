extends Node3D
class_name Enemy

static var staticInstEnemArr: Array[Enemy]
@export var zigLen:int
@export var zigLenRanScale:float
var zigLenAdd:int=0
var internalZigLen:int
@export var zigVel:Vector2
@export var backOffDist:float
@export var breakIntensity:float
@export var straightLikelyhood:float#must be between 0 & 1

@export var hpBase: float #expected hp for regular enemy is ~10-20
@export var drBase: float #expected dr for regular enemy is ~0.05-0.08
var localHp:int
var localDr:float
var localLvl:int

var knockBackTime:float
var moveVec:Vector2
var seesPlayer:bool

@onready var myBody:RigidBody3D = $"."
@onready var myRay:RayCast3D =$"RayCast3D"

func _init() -> void:
	staticInstEnemArr.append($".")
	
func _ready() -> void:
	self.add_to_group("Enemies")
	#print_debug(myBody.name)
	moveVec=Vector2([-zigVel.x,zigVel.x].pick_random(),zigVel.y)
	localLvl=1+int(float(sceneOriginManager.worldLevel) / staticInstEnemArr.size())
	localHp= int(hpBase*pow(localLvl,1.3))#scaling factor is the 1.3
	localDr= pow(1-drBase,float(localLvl)/6)#scaling factor is the /6
	#end of ready
	localReady()
	
func _physics_process(delta: float) -> void:
	if(sceneOriginManager.lvltime<5):pass #enemies do not work until 5 seconds have passed.
	#ray that looks at player.
	myRay.look_at(Player.staticInstance.global_position,Vector3.UP)
	myRay.target_position.z = -global_position.distance_to(Player.staticInstance.global_position)
	#end of phys process
	localPhysProcess(delta)

static func debugPrintInstArr()-> void:
	var printout:String="Enemy list;"
	for item in staticInstEnemArr:
		printout = str(printout + " " + item.name)
	print_debug(printout)
	
func hurt(damage:int,knockBack:float,knockAngle:Vector3)->void:
	myBody.linear_velocity+=knockAngle*knockBack
	knockBackTime=0.25
	#end of hurt
	print_debug("Dmg "+str(damage)+": Dmg after dr "+str(damage*localDr))
	localHp-= int(damage*localDr)+1 # add 1 after dmg calc so it can never be 0
	if(localHp<=0): die()
	localHurt(damage,knockBack,knockAngle)
	
func moveProcess(delta:float)->void:
	if(myRay.is_colliding()):
		var hitNode:Node3D = myRay.get_collider()
		if(hitNode!=null and hitNode.name=="Player"):
			seesPlayer=true
			zigLenAdd=0
			var pps:Vector3=Player.staticInstance.global_position
			pps.y=global_position.y
			look_at(pps)
			#print_debug("HitPlayer!")
			myRay.debug_shape_custom_color = Color.BLUE
		else : seesPlayer=false
	else : seesPlayer=false
	if(knockBackTime>0):knockBackTime-=delta
	if(internalZigLen<=0):
		internalZigLen=zigLen+randi_range(-int(zigLen*zigLenRanScale),int(zigLen*zigLenRanScale))+zigLenAdd#reset zig/zag distance
		myBody.linear_velocity=lerp(myBody.linear_velocity,Vector3.ZERO,breakIntensity)#stop in place to turn
		moveVec.x = -moveVec.x#flip zig/zag direction
		if(!seesPlayer):
			zigLenAdd+=1
			myRay.debug_shape_custom_color = Color.ORANGE
			rotate_y(randf_range(-180,180))
	else:
		internalZigLen-=1
		#if too close; negate move velocity addition
		if(knockBackTime<=0): #can't move forward while knockedback
			if(global_position.distance_to(Player.staticInstance.position)>backOffDist):
				myBody.linear_velocity+=(-global_basis.z*moveVec.y)
			else: myBody.linear_velocity+=(global_basis.z*moveVec.y)
		var isFwd:bool = (randf()>straightLikelyhood)#affects how 'forward' they move
		myBody.linear_velocity+=(global_basis.x*moveVec.x)*int((!seesPlayer or isFwd))#strafing
	
func localHurt(damage:int,knockBack:float,knockAngle:Vector3)->void:
	pass
	
func localReady()->void:
	pass
	
func localPhysProcess(delta:float)->void:
	moveProcess(delta)

func die():
	print_debug(name + " has died")
	queue_free()
