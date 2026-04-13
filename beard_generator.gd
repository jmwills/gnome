extends Node3D


@export var head_mesh : MeshInstance3D

@export var test_sphere : MeshInstance3D

var head_area : Area3D

var _horizontal_span := 2.0
var _horizontal_casts := 100

var _horizontal_min_x := 0.0
var _horizontal_max_x := 0.0

var _raycast_start_distance := 1.0
var _raycast_length := 5.0

var raycast : RayCast3D
var temporary_collision_shape : CollisionShape3D

var _y_level_of_beard_top := 0.0 # y_level according to head where beard should start
var top_y_level := 0.0

var default_beard_length := 1
var beard_thickness := .05

var beard_mesh : Mesh

@export var top_curve : Curve = Curve.new()

@export var bottom_curve : Curve = Curve.new()

@export var _generate_beard : bool :
	set(val):
		generate_beard()

func _ready() -> void:
	head_area = Area3D.new()
	temporary_collision_shape = CollisionShape3D.new()
	
	top_y_level = to_local(head_mesh.position + (Vector3.UP*_y_level_of_beard_top)).y

	create_temporary_collision_shape()
	create_raycast()
	get_head_bounds()

	generate_beard()

func _create_test_sphere(position : Vector3):
	var new_test_sphere = test_sphere.duplicate()
	new_test_sphere.position = position
	add_child(new_test_sphere)

func create_temporary_collision_shape():
	temporary_collision_shape.shape = head_mesh.mesh.create_trimesh_shape()
	temporary_collision_shape.transform = head_mesh.transform
	
	add_child(head_area)
	head_area.add_child(temporary_collision_shape)

func create_raycast():
	raycast = RayCast3D.new()
	raycast.collide_with_areas = true
	raycast.collide_with_bodies = false
	raycast.exclude_parent = false
	raycast.target_position = Vector3.FORWARD * _raycast_length
	add_child(raycast)


func get_head_bounds():
	var _bounds_check_resolution = .01
	raycast.position = Vector3(-_horizontal_span, top_y_level, 0) + (-Vector3.FORWARD * _raycast_start_distance)

	while !raycast.is_colliding():
		raycast.position += Vector3(_bounds_check_resolution, 0, 0)
		raycast.force_raycast_update()
	_horizontal_min_x = raycast.position.x

	raycast.position = Vector3(_horizontal_span, top_y_level, 0) + (-Vector3.FORWARD * _raycast_start_distance)
	raycast.force_raycast_update()

	while !raycast.is_colliding():
		raycast.position -= Vector3(_bounds_check_resolution, 0, 0)

		raycast.force_raycast_update()
	_horizontal_max_x = raycast.position.x

func generate_beard():
	var hor_delta = (abs(_horizontal_max_x - _horizontal_min_x)) / _horizontal_casts
	raycast.position = Vector3(_horizontal_min_x, top_y_level, 0) + (-Vector3.FORWARD * _raycast_start_distance)

	# [top point, bottom point, normal]
	var points = []

	for idx in _horizontal_casts:
		

		# do top offset
		var top_curve_offset = top_curve.sample((2*(float(idx)/_horizontal_casts)))
		if idx > (_horizontal_casts/2):
			top_curve_offset = top_curve.sample(1-(2*((float(idx)/_horizontal_casts)-.5)))

		# do bottom offset

		var bottom_curve_offset = bottom_curve.sample((2*(float(idx)/_horizontal_casts)))
		if idx > (_horizontal_casts/2):
			bottom_curve_offset = bottom_curve.sample(1-(2*((float(idx)/_horizontal_casts)-.5)))
		

		raycast.position.x += hor_delta
		raycast.position.y = top_y_level + top_curve_offset

		# find collision point
		var collision_point = Vector3.ZERO
		raycast.force_raycast_update()
		if raycast.is_colliding():
			collision_point = raycast.get_collision_point()
		else:
			continue
		
		# find end of beard
		var adjusted_beard_length = bottom_curve_offset + default_beard_length
		
		var top_point = collision_point
		_create_test_sphere(top_point)
		var bottom_point = Vector3(collision_point.x, top_y_level - adjusted_beard_length, collision_point.z)
		points.append([top_point, bottom_point, raycast.get_collision_normal()])


	# Initialize the ArrayMesh.
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)

	# Outer Layer

	var st = SurfaceTool.new()

	st.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	for idx in range(points.size()-1, -1, -1):
		var top_point : Vector3 = points[idx][0]
		var bottom_point : Vector3 = points[idx][1]
		var point_normal : Vector3 = points[idx][2]
		var is_edge := idx==0 or idx==points.size()-1
		var thickness_offset = point_normal * beard_thickness
		st.add_vertex(top_point + thickness_offset)
		st.add_vertex(bottom_point + thickness_offset)
	st.index()
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, st.commit_to_arrays())

	# Inner Layer

	st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	for idx in range(points.size()):
		var top_point : Vector3 = points[idx][0]
		var bottom_point : Vector3 = points[idx][1]
		var point_normal : Vector3 = points[idx][2]
		var is_edge := idx==0 or idx==points.size()-1

		st.add_vertex(top_point)
		st.add_vertex(bottom_point)
	st.index()
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, st.commit_to_arrays())

	# Top
	st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	for idx in range(points.size()-1, -1, -1):
		var is_first_edge := idx==0
		var is_last_edge := idx==points.size()-1
		var top_point : Vector3 = points[idx][0]
		var next_top_point : Vector3 = points[idx-1][0]
		var point_normal : Vector3 = points[idx][2]
		var thickness_offset = point_normal * beard_thickness

		st.add_vertex(top_point)
		st.add_vertex(top_point+thickness_offset)
		if is_first_edge:
			continue
		st.add_vertex(next_top_point)
		st.add_vertex(top_point+thickness_offset)
	st.index()
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, st.commit_to_arrays())
	
	# Bottom
	st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	for idx in range(points.size()-1):
		var is_first_edge := idx==0
		var is_last_edge := idx==points.size()-1
		var top_point : Vector3 = points[idx][1]
		var next_top_point : Vector3 = points[idx+1][1]
		var point_normal : Vector3 = points[idx][2]
		var thickness_offset = point_normal * beard_thickness

		st.add_vertex(top_point)
		st.add_vertex(top_point+thickness_offset)
		st.add_vertex(next_top_point)
		if is_last_edge:
			continue
		st.add_vertex(top_point+thickness_offset)
	st.index()
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, st.commit_to_arrays())
	
	# Edges
	for idx in [0, points.size()-1]:
		st = SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
		var top_point : Vector3 = points[idx][1]
		var bottom_point : Vector3 = points[idx][0]
		var point_normal : Vector3 = points[idx][2]
		var thickness_offset = point_normal * beard_thickness

		if idx == 0:
			# flip
			var holding = top_point
			top_point = bottom_point
			bottom_point = holding

		st.add_vertex(top_point)
		st.add_vertex(top_point+thickness_offset)
		st.add_vertex(bottom_point)
		st.add_vertex(bottom_point+thickness_offset)
		st.add_vertex(top_point+thickness_offset)
		
		st.index()
		arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, st.commit_to_arrays())


	#beard_mesh = st.commit()
	var beard_mesh_instance : MeshInstance3D = MeshInstance3D.new()
	beard_mesh_instance.mesh = arr_mesh
	add_child(beard_mesh_instance)
