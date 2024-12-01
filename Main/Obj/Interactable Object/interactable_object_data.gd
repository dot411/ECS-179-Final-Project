class_name InteractableObjectData
extends ObjData

#when set to false, only activation is allowed.
#deactivation can still be forced through trigger
@export var allow_deactivation:bool = false
#empty string means that no resource is rquired for activation
@export var requires_resource:String = ""
#0 means that no resource is required
@export_range(0, 64, 1) var requires_resource_amount:int = 0
#items to give to the interactor when activated
@export var give_inventory:Array[ItemData] = []
