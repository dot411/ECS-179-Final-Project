class_name PlayerData
extends Resource

@export_range(0.0, 5.0, 0.01) var interact_range:float = 0.8
@export_range(1.0, 5.0, 0.01) var run_speed_multiplier:float = 2.0
@export_range(0.0, 100.0, 0.01) var run_fatigue_drain_per_second:float = 30.0
@export_range(0.0, 100.0, 0.01) var fatigue_recovery_per_second:float = 15.0
