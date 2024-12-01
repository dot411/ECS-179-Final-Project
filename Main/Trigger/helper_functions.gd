class_name HelperFunctions
extends Resource

func unit_attribute(buffer:TriggerBuffer, _unit:TriggerUnit, attribute:TriggerUnit.unit_attributes):
	var unit = _unit.run(buffer)
	if attribute == TriggerUnit.unit_attributes.Attack: return unit.attack
	elif attribute == TriggerUnit.unit_attributes.AbilityPower: return unit.ability_power
	return 0
