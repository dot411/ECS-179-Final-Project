class_name HP_ObjData
extends ObjData

##only damage types from the array are effective against this object
@export var vulnerable_to_damage:Array[Damage.Types] = [Damage.Types.Flat]
##resistance value from 0.0 to 1.0 for each index in vulnerable_to_damage.
##If greater than 0, damage will be reduced by the proportion of resistance.
@export_range(0.0, 1.0, 0.01) var resistance_to_damage:Array[float] = []
@export var max_HP:int = 100
var HP:int
