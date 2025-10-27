#hello github 
extends Node3D
class_name sceneOriginManager

static var staticInst: sceneOriginManager
static var worldLevel: int
@export var devLevel: int
#textureVars
var worldt :StandardMaterial3D
var floort :StandardMaterial3D
var skyt :StandardMaterial3D
var nois:FastNoiseLite 
var worldTexNam: String = ".import"
var floorTexNam: String = ".import"
var skyTexNam: String = ".import"
#textureVars
#worldGenVars
var mapGenArr = []
@export var xyScale: Vector2
@export var walkScale: int
@export var stepScale: int
@export var roomScale: int
#worldGenVars
#objs for world instantiation
var wallObj = preload("res://MapObj/offset_cube.tscn")
var floorObj= preload("res://MapObj/offset_ceiling_floor.tscn")
var lightObj= preload("res://MapObj/light_obj.tscn")
#objs for world instantiation
static var lvltime:float=0

func _init() -> void:
	staticInst = $"."
	
func _ready() -> void:
	Enemy.debugPrintInstArr()
	var noiseTex:NoiseTexture2D = load("res://Mats/BackGNoise.tres")
	nois = noiseTex.noise
	#texture randomisation
	worldt = load("res://Mats/WorldMaterial.tres")
	floort = load("res://Mats/FloorMaterial.tres")
	skyt = load("res://Mats/SkyMaterial.tres")
	var texDir := DirAccess.open("res://Tex").get_files()
	while worldTexNam.contains(".import"):
		worldTexNam=texDir[randi_range(0,len(texDir)-1)]
	while floorTexNam.contains(".import") or floorTexNam == worldTexNam:
		floorTexNam=texDir[randi_range(0,len(texDir)-1)]
	while skyTexNam.contains(".import") or skyTexNam == worldTexNam or skyTexNam == floorTexNam:
		skyTexNam=texDir[randi_range(0,len(texDir)-1)]
	worldt.albedo_texture = load("res://Tex/"+worldTexNam)
	floort.albedo_texture = load("res://Tex/"+floorTexNam)
	skyt.albedo_texture  = load("res://Tex/"+skyTexNam)
	#texture randomisation
	#world generation
	xyScale+=Vector2(randi_range(xyScale.x-5,xyScale.x+5),
	randi_range(xyScale.y-5,xyScale.x+5))
	for i in range(int(xyScale.y)):
		mapGenArr.append([])
		mapGenArr[i].resize(int(xyScale.x))
		mapGenArr[i].fill(1)
	
	#printMapDebug()
	var midY:int = int(float(len(mapGenArr))/2)
	var midX:int = int(float(len(mapGenArr[midY]))/2)
	#mapGenerationProcesses
	mapGenArr=random_walk_gen(midX,midY,mapGenArr)#generates map
	mapGenArr=randomReplace(mapGenArr,6,2)#randomly generate 6 lights
	mapGenArr=randomReplace(mapGenArr,5,3)
	#mapGenerationProcesses
	mapGenArr=startRoom(midX,midY,mapGenArr)
	mapGenArr=randomReplaceWall(4,24,mapGenArr)
	#printMapDebug()
	#world generation
	#world obj instantiation
	for y in range(mapGenArr.size()):
		for x in range(mapGenArr[y].size()):
			if(mapGenArr[y][x]==1): instanceObj(Vector2i(x,y),wallObj)
			else: instanceObj(Vector2i(x,y),floorObj)
			match mapGenArr[y][x]:
				2: #map light
					instanceObj(Vector2i(x,y),lightObj)
				3:#enemy
					instanceObj(Vector2i(x,y),load("res://MapObj/generic_enemy.tscn"))
				4:#doorWall
					instanceObj(Vector2i(x,y),load("res://MapObj/door_obj.tscn"))
				99: #player postion
					Player.staticInstance.position=Vector3(x*2,1,y*2)
					#print_debug(Player.staticInstance.name)

func printMapDebug():
	var debStr:String
	for i in range(mapGenArr.size()):
		debStr=(debStr+" \n "+str(mapGenArr[i]))
	print_debug(debStr)



func randomReplaceWall(val:int,times:int,arr):
	var gotWall:bool
	var posX:int=0
	var posY:int=0 
	for i in range(times):
		gotWall=false
		#print_debug("New Wall "+str(i))
		while !gotWall:
			#print_debug("Finding Wall at "+str(i))
			posY= randi_range(1,len(arr)-2)
			posX= randi_range(1,len(arr[posY])-2)
			if (arr[posY][posX] == 1 and 
			(arr[posY+1][posX] != 1 or 
			arr[posY-1][posX] != 1 or 
			arr[posY+1][posX+1] != 1 or 
			arr[posY-1][posX+1] != 1 or 
			arr[posY+1][posX-1] != 1 or 
			arr[posY-1][posX-1] != 1 or 
			arr[posY][posX+1] != 1 or 
			arr[posY][posX-1] != 1
			)):gotWall=true
		arr[posY][posX] = val
	return arr

func checkSpot(posX: int,posY: int,arr):
	#print_debug(arr.size())
	return !((posY<=1) or (posY>=arr.size()-1) or (posX<=1) or (posX>=arr[0].size()-1))
	
func replaceSpot(posX:int,posY:int,arr,val:int):
	if checkSpot(posX,posY,arr):
		arr[posY][posX]=val
	return arr

func replaceRegion(posX:int,posY:int,arr,val:int,sqradius:int):
	if(sqradius%2==0):sqradius+=1
	posX-=int(float(sqradius)/2)
	posY-=int(float(sqradius)/2)
	var Xreset: int =posX
	for a in range(sqradius):
		for b in range(sqradius):
			arr=replaceSpot(posX,posY,arr,val)
			posX+=1
		posX=Xreset
		posY+=1
	return arr

func startRoom(posX:int,posY:int,arr):
	arr=replaceRegion(posX,posY,arr,1,5)
	arr=replaceRegion(posX,posY,arr,0,3)
	arr=replaceSpot(posX+2,posY,arr,0)
	arr=replaceSpot(posX-2,posY,arr,0)
	arr=replaceSpot(posX,posY+2,arr,0)
	arr=replaceSpot(posX,posY-2,arr,0)
	arr=replaceSpot(posX,posY,arr,99)
	return arr

func randomFlatXY():
	return [Vector2i([-1,1].pick_random(),0),Vector2i(0,[-1,1].pick_random())].pick_random()

func random_walk_gen(wposX,wposY,arr):
	#print_debug(arr.size()-2)
	var walkAngle:Vector2i = randomFlatXY()
	var walkPos:Vector2i=Vector2i(wposX,wposY)
	for walk in range(walkScale):
		randomize()
		for step in range(stepScale+randi_range(-int(float(stepScale)/3),
		int(float(stepScale)/3))):
			walkPos+=walkAngle
			if(!checkSpot(walkPos.x,walkPos.y,arr)):
				walkAngle=-walkAngle
				walkPos+=walkAngle
			arr[walkPos.y][walkPos.x]=0
		walkAngle=randomFlatXY()
		if(randi_range(1,3)==3):
			arr=replaceRegion(walkPos.x,walkPos.y,arr,0,roomScale+randi_range(-int(roomScale/3),int(roomScale/3)))
	return arr
	
func randomReplace(arr,count:int,val:int):
	var ranPos: Vector2i
	while count>0: 
		
		ranPos= Vector2i(randi_range(1,arr[0].size()-2),randi_range(1,arr.size()-2))
		if(arr[ranPos.y][ranPos.x]==0):
			count-=1
			arr[ranPos.y][ranPos.x]=val
	return arr
	
func instanceObj(instPos:Vector2i,obj):
	var localInst = obj.instantiate()
	localInst.position += Vector3(instPos.x*2,0,instPos.y*2)
	add_child(localInst)
	
func _process(delta: float) -> void:
	#if(nois.seed<100):nois.seed+=1
	#else: nois.seed=0
	lvltime+=delta
