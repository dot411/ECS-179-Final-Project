class_name ItemData
extends BaseData

@export var name:String = ""
@export var description:String = ""
@export_dir var asset_path
@export_range(1, 64, 1) var stack_limit:int = 1
@export_range(1, 64, 1) var amount:int = 1
var slot_id = 0
