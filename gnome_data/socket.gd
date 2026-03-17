class_name SocketInfo extends Resource

enum SocketType {EYE, EAR, NOSE, HAT, HEAD, BODY, LEG, MOUTH}

@export var type : SocketType
@export var scale_transform : Vector3
@export var scale_x_as_scalar := false
@export var inherit_parent_scale := false
@export var position_transform : Vector3
@export var rotation_transform : Vector3