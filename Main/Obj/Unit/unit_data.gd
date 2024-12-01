class_name UnitData
extends HP_ObjData

@export_dir var asset_path
@export_range(0.0, 10.0, 0.01) var speed:float = 1.0
@export_range(0.0, 1000.0, 0.01) var max_fatigue:float = 100.0
var fatigue:float = 0.0
@export var attack:int = 10
@export var ability_power:int = 10
@export_range(0.0, 20.0, 0.01) var vision:float = 5
@export var player_data:PlayerData
@export var AI_data:UnitAIData
@export var abilities:Array[AbilityData] = []
var inventory:Array[ItemData] = []
var interact_range:float = 0.8
