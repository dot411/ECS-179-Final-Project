class_name AbilityData
extends BaseData

@export var cast_animation:String = ""
@export var stationary:bool = false
@export_range(0.0, 20.0, 0.01) var AI_cast_range:float = 1.0
@export_range(0.0, 300.0, 0.01) var cooldown:float = 1.0
@export var channeling_track:Array[ChannelingInterval] = []
var cooldown_time_left:float = 0
