@tool

extends Node3D

var default_node_name = "place-body"

var socket_prefix = "place-"

var socket_map : Dictionary[String, Node3D]

var body_root : Node3D

@export var _do_visualize_gnome : bool :
	set(val):
		_visualize_gnome()

@export var gnome : Gnome# :
# 	set(val):
# 		gnome = val
# 		_visualize_gnome()

var count := 0

# func _ready() -> void:
# 	_visualize_gnome()

var done_generation : = false :
	set(val):
		done_generation = val
		print("Generation : ", val)

func _ready() -> void:
	_visualize_gnome()
	# if !Engine.is_editor_hint():
	# 	var tween = create_tween()
	# 	tween.tween_callback(_visualize_gnome)
	# 	tween.set_loops()	
	# 	tween.tween_interval(100)	

func _visualize_gnome():
	if body_root:
		body_root.free()
	if !gnome:
		gnome = GnomeGenerator.get_new_gnome() # will be removed when testing this feature over.
	body_root = Node3D.new()
	body_root.name = default_node_name
	add_child(body_root)
	do_gen_step(self)
	do_effects()
	done_generation = true


func get_all_child_count(node):
	var count = node.get_child_count()
	for child in node.get_children():
		count += get_all_child_count(child)
	return count

func do_gen_step(node : Node3D):
	for child in node.get_children():
		if socket_prefix in child.name: ## Therefore it's a socket
			var flip : = false
			var socket_name = child.name.replace(socket_prefix, "")
			for i in range(10):
				if socket_name.ends_with("_00"+str(i)):
					socket_name = socket_name.replace("_00"+str(i), "")
			child.name = socket_name
			var socket_type_name = socket_name
			if "_r" in socket_name or "_l" in socket_name:
				socket_type_name = socket_name.split("_")[0]
			if "_l" in child.name:
				flip = true
			var new_appendage = gnome.socket_to_appendage_data[socket_type_name.to_upper()] as Appendage
			var new_appendage_visual = new_appendage.scene.instantiate()
			if flip:
				new_appendage_visual.scale.x = -1
			if !new_appendage.inherit_parent_scale:
				child.top_level = true
			child.add_child(new_appendage_visual)
			new_appendage_visual.position += new_appendage.position_modification
			new_appendage_visual.rotation_degrees += new_appendage.rotation_modification
			
			new_appendage_visual.scale *= new_appendage.scale_modification
			child.top_level = false
			socket_map[socket_name] = new_appendage_visual
			do_gen_step(new_appendage_visual)
		do_gen_step(child)

func do_effects():
	pass

func add_appendage_to_socket(socket : Node3D, socket_info : SocketInfo, appendage : Appendage):
	pass

func make_mesh_children_transparent(node: Node3D):
	for child in node.get_children():
		if child is MeshInstance3D:
			child.transparency = .8

func do_pallette():
	pass

func _physics_process(delta: float) -> void:
	_animate_eyes(delta)
	if !Engine.is_editor_hint():
		if Input.is_action_just_pressed("generic_test_key"):
			gnome = null
			_visualize_gnome()

func _animate_eyes(delta : float):
	var max_eye_rotation = .95
	for eye_socket in ["eye_l", "eye_r"]:
		if eye_socket in socket_map.keys():
			#socket_map[eye_socket].look_at(socket_map[eye_socket].global_position + Vector3.FORWARD)
			print(socket_map[eye_socket].rotation)
			socket_map[eye_socket].look_at(get_viewport().get_camera_3d().global_position, Vector3.UP, true)
			socket_map[eye_socket].rotation = socket_map[eye_socket].rotation.clamp(Vector3(-max_eye_rotation , -max_eye_rotation , 0), Vector3(max_eye_rotation , max_eye_rotation , 0))