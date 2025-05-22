extends Node2D

const ROWS = 5
const COLUMNS = 9
const TILE_WIDTH = 1480/COLUMNS
const TILE_HEIGHT = 975/ROWS

var developer_mode = true
var tile_origin = Vector2(509, 75)

func _ready():
	pass

func get_tile_at_position(pos: Vector2) -> Vector2i:
	var local_pos = pos - global_position - tile_origin
	var col = int(local_pos.x / TILE_WIDTH)
	var row = int(local_pos.y / TILE_HEIGHT)

	if col < 0 or col >= COLUMNS or row < 0 or row >= ROWS:
		return Vector2i(-1, -1)

	return Vector2i(col, row)

func get_world_position_from_tile(tile: Vector2i) -> Vector2:
	return global_position + tile_origin + Vector2(tile.x * TILE_WIDTH, tile.y * TILE_HEIGHT)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var tile = get_tile_at_position(event.position)
		var world_pos = get_world_position_from_tile(tile)
		
		if developer_mode:
			print("Clicked tile: ", tile)
			place_debug_marker(world_pos)

func place_debug_marker(pos: Vector2):
	var marker = ColorRect.new()
	marker.color = Color.RED
	marker.size = Vector2(TILE_WIDTH, TILE_HEIGHT)
	marker.position = pos
	add_child(marker)
