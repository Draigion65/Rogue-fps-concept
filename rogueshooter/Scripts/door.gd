extends Node3D
@onready var doorThing:Node3D = $Door
@onready var doorArea:Area3D = $DoorResponder
@export var doorDownScalar:float = 0.2
@export var doorDownTime:float=3
var doorTimer:float=0
@export var doorUpScalar:float = 0.1
var doorUpY:float
var doorDownY:float
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	doorUpY=doorThing.position.y
	doorDownY=doorUpY-2.1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if(doorArea.has_overlapping_bodies()):
		doorTimer=doorDownTime
	if(doorTimer>0):
		doorTimer -= delta
		doorThing.position.y = lerpf(doorThing.position.y,doorDownY,doorDownScalar)
	else:
		doorThing.position.y = lerpf(doorThing.position.y,doorUpY,doorUpScalar)
