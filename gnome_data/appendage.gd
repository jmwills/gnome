class_name Appendage extends Resource

## This is one "appendage" item, so one bespoke nose, mouth, etc -- not its visual representation

@export var scene : PackedScene
@export var socket_type : SocketInfo.SocketType
@export var override_sockettype_transforms : bool = false


var scale_modification : Vector3 = Vector3.ONE
var rotation_modification : Vector3 = Vector3.ONE
var position_modification : Vector3 = Vector3.ONE
var inherit_parent_scale := false