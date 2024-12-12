class_name Fireplace
extends InteractableObject

@export var firewood: Destructible  # Reference to the firewood (destructible object)
@export var required_resource: String  # Name of the resource required (e.g., "Matches")
@export var required_amount: int = 1  # Amount of resource required
@export var burned_texture: Texture
@export var burn_animation: AnimationPlayer

func interact(unit):
	# Check if the player has the required resource (matches) and enough quantity
	# if firewood and firewood.data.HP > 0:  # Firewood is still "alive"
		if required_resource != "" and required_amount != 0:
			if unit.spend_item_based_on_name(required_resource, required_amount):
				if burn_animation:
					await get_tree().create_timer(1).timeout
					$"FirewoodSprite".visible = false
					burn_animation.play("BurningAnimation")
				await get_tree().create_timer(3).timeout
				firewood.deactivate()  # Call the firewood's deactivate method to burn it
				# await get_tree().create_timer(3).timeout
				
				
				$"FirewoodSprite".visible = true
				if burned_texture:
					$"FirewoodSprite".texture = burned_texture
				print("You lit the firewood!")
			else:
				print("You need matches to light the firewood.")
