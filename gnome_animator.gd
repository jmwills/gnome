class_name GnomeAnimator extends Node3D

@export var gnome_skeleton : GnomeSkeleton

var walking_time_wave = 0.0
var gnome_speed = 0.0

func _physics_process(delta: float) -> void:
	gnome_speed = gnome_skeleton.gnome_data.attributes["speed"]
	if gnome_speed > 0.0:
		walking(delta)
	else:
		idle(delta)

func walking(delta : float):
	for leg_name in ["leg_r", "leg_l"]:
		var leg = gnome_skeleton.appendage_map[leg_name]
		leg.rotation_degrees.x = cos(gnome_speed * walking_time_wave * 2.0 * PI) * 50 * (-1 if "_l" in leg_name else 1)
		print(leg.rotation_degrees.x, " ", sin(walking_time_wave * PI * gnome_speed))
	var head = gnome_skeleton.appendage_map["head"]
	var hat = gnome_skeleton.appendage_map["hat"]
	hat.rotation_degrees.x = lerpf(hat.rotation_degrees.x, -10.0 * gnome_speed, delta * 5.0)
	head.position.y = (cos((walking_time_wave + .5) * 4.0 * PI * gnome_speed) * .1) - .1
	walking_time_wave += delta

func idle(delta : float):
	for leg_name in ["leg_r", "leg_l"]:
		var leg = gnome_skeleton.appendage_map[leg_name]
		leg.rotation_degrees.x = lerpf(leg.rotation_degrees.x, 0, delta * 5.0)
	var head = gnome_skeleton.appendage_map["head"]
	var hat = gnome_skeleton.appendage_map["hat"]
	head.position.y = lerpf(head.position.y, 0, delta * 5.0)
	hat.rotation_degrees.x = lerpf(hat.rotation_degrees.x, 0, delta * 5.0)

#sin(frequency * time * 2.0 * PI) * amplitude 
