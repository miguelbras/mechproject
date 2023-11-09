# adapted from https://kidscancode.org/godot_recipes/3.x/ui/minimap/

extends MarginContainer

@export var player : NodePath
@export var arena : MeshInstance3D
@export var zoom = 1.5
@export var view_size = Vector2(10, 10)

@onready var grid = $MarginContainer/Grid
@onready var player_marker = $MarginContainer/Grid/PlayerMarker
@onready var mob_marker = $MarginContainer/Grid/MobMarker
@onready var alert_marker = $MarginContainer/Grid/AlertMarker

@onready var icons = {"mob": mob_marker, "alert": alert_marker}

var grid_scale
var markers = {}

func _ready():
	player_marker.position = size / 2
	var arena_size = view_size# Vector2(arena.mesh.size.x, arena.mesh.size.z)
	grid_scale = size / (arena_size * zoom)
	var map_objects = get_tree().get_nodes_in_group("minimap_objects")
	for item in map_objects:
		var new_marker = icons[item.minimap_icon].duplicate()
		grid.add_child(new_marker)
		new_marker.show()
		markers[item] = new_marker
		item.removed.connect(_on_object_removed)
	
func _process(delta):
	if not player:
		return
	for item in markers:
		var item_pos = Vector2(item.position.x, item.position.z)
		var player_pos = Vector2(get_node(player).position.x, get_node(player).position.z)
		var obj_pos = (item_pos - player_pos) * grid_scale + size / 2
		obj_pos.x = clamp(obj_pos.x, 0, grid.get_rect().size.x)
		obj_pos.y = clamp(obj_pos.y, 0, grid.get_rect().size.y)
		markers[item].position = obj_pos
		if grid.get_rect().has_point(obj_pos + grid.get_rect().position):
			markers[item].scale = Vector2(0.75, 0.75)
		else:
			markers[item].scale = Vector2(1, 1)

func _on_object_removed(object):
	if object in markers:
		markers[object].queue_free()
		markers.erase(object)

