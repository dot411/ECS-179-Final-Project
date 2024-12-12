class_name Firewood
extends Destructible

@export var burned_texture: Texture  # The texture to show after the firewood is burned
@export var burn_animation: AnimationPlayer  # If you want an animation of fire burning the wood

# When the firewood is activated (i.e., placed in the scene)
func _ready():
	# Set initial state if necessary (e.g., texture, animation)
	pass

# This function will be called when the firewood is burned (deactivated)
func deactivate():
	# Change texture to show burned state (or trigger an animation)

	
	# If you want to play a burning animation
  	# Assume you have a "burning" animation

	# Call the parent class's deactivate to disable collision
	super()

# Override the death method if needed for specific effects when firewood is "destroyed"
func death():
	# You can add any specific behavior when the firewood "dies", like dropping items
	# or additional effects.
	
	super()
