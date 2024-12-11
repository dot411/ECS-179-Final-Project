class_name HP_Obj
extends Obj

func init():
	super()
	if data.active: data.HP = data.max_HP

func HP_changed():
	var proportion = float(data.HP) / float(data.max_HP)
	#if get_body().has_node("Sprite"):
		#get_body().get_node("Sprite").scale = Vector2(proportion, proportion)

func heal(value:FloatPoint):
	if data.HP >= data.max_HP: return false
	var v = int(value.run(trigger_buffer))
	if data.HP + v > data.max_HP:
		v = data.max_HP - data.HP
	data.HP += v
	HP_changed()
	Utility.get_UI_Scene().obj_healed(self, v)
	return true

func take_damage(value:FloatPoint, damage_type:Damage.Types = Damage.Types.Flat):
	if data.HP <= 0: return false
	var vulnerable_to_damage = data.vulnerable_to_damage
	if !vulnerable_to_damage.has(damage_type): return false
	var damage = value.run(trigger_buffer)
	var damage_type_i = vulnerable_to_damage.find(damage_type)
	var resistance_to_damage = data.resistance_to_damage
	if resistance_to_damage.size() > damage_type_i:
		damage *= clampf((1.0 - resistance_to_damage[damage_type_i]), 0.0, 1.0)
	data.HP = int(clampf(data.HP - damage, 0.0, 100.0))
	HP_changed()
	Utility.get_UI_Scene().obj_damaged(self, int(damage))
	if data.HP == 0: death()
	return true
