class_name GameMessageManager
extends Control

@onready var label = $TextBoxContainer/Panel/MarginContainer/Panel/HBoxContainer/Label2
@onready var animation_player = $AnimationPlayer
@onready var game_message = $"."
# Queue for holding messages
var message_queue: Array = []
var is_displaying: bool = false

# Add a message to the queue
func add_message(message: String, duration: float):
	message_queue.append({ "text": message, "duration": duration })
	if not is_displaying:
		display_next_message()

# Display the next message in the queue
func display_next_message():
	if message_queue.size() == 0:
		is_displaying = false
		return  # Stop if there are no more messages

	is_displaying = true
	var current_message = message_queue.pop_front()  # Dequeue the first message
	label.text = current_message["text"]

	# Play fade_in animation and wait until it completes
	animation_player.play("fade_in")
	while animation_player.is_playing():
		await get_tree().process_frame  # Wait for the next frame until fade_in is done

	# Wait for the message duration
	await get_tree().create_timer(current_message["duration"]).timeout

	# Play fade_out animation and wait until it completes
	animation_player.play("fade_out")
	while animation_player.is_playing():
		await get_tree().process_frame 

	# Continue displaying the next message
	display_next_message()

# Clear all messages in the queue
func clear_messages():
	message_queue.clear()
	label.text = ""
	is_displaying = false
	print("Messages cleared.")
	game_message.visible = false # test
	
