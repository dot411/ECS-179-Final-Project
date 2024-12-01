class_name AbilityObjData
extends ObjData

##temporarily disable when player is near
@export var disable_when_player_is_nearby = false
##delay time before this object casts its first ability
@export_range(0.0, 600.0, 0.01) var start_delay:float = 0.0
##ability cooldown
@export_range(0.0, 10.0, 0.01) var cooldown:float = 1.0
##this object can ony cast abilities within the distance limit
@export_range(0.0, 30.0, 0.01) var max_aim_distance: float = 5.0
##this object can only cast abilities in the direction within the angle's range
@export_range(0.0, 360.0, 0.01) var max_aim_angle:float = 360
##maximum amount of coexisting units created by this object.
@export_range(-1, 30, 1) var unit_spawn_limit:int = -1
##ability's effects
@export var position_effects:Array[PositionEffect] = []
