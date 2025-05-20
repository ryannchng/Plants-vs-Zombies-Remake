extends Node2D

const ROWS = 5
const COLUMNS = 9
const TILE_WIDTH = 1480/COLUMNS
const TILE_HEIGHT = 975/ROWS

var developer_mode = true
var tile_origin = Vector2(509, 75)
var current_plant = null
var sun_count = 50

var tiles = {}

class LawnTile:
	var position: Vector2i
	var world_position: Vector2
	var occupied: bool = false
	var plant = null
	var visual_indicator = null
	
	func _init(pos: Vector2i, w_pos: Vector2):
		position = pos
		world_position = w_pos
		
	func can_place_plant() -> bool:
		return not occupied
		
	func place_plant(plant_instance) -> bool:
		if can_place_plant():
			plant = plant_instance
			occupied = true
			return true
		return false
		
	func clear_plant():
		plant = null
		occupied = false

var tile_highlight: ColorRect
var plants_container: Node2D

func _ready():
	plants_container = Node2D.new()
	plants_container.name = "PlantsContainer"
	add_child(plants_container)
	
	create_tile_highlight()
	
	initialize_tiles()

func initialize_tiles():
	for row in range(ROWS):
		for col in range(COLUMNS):
			var tile_pos = Vector2i(col, row)
			var world_pos = get_world_position_from_tile(tile_pos)
			var tile_data = LawnTile.new(tile_pos, world_pos)
			tiles[tile_pos] = tile_data
			
			if developer_mode:
				create_tile_debug_visual(tile_data)

func create_tile_debug_visual(tile_data: TileData):
	# Create a semi-transparent visual for each tile in developer mode
	var marker = ColorRect.new()
	marker.color = Color(1, 1, 1, 0.2)
	marker.size = Vector2(TILE_WIDTH - 2, TILE_HEIGHT - 2)
	marker.position = tile_data.world_position + Vector2(1, 1)
	add_child(marker)
	
	# Add coordinates text for debugging
	var label = Label.new()
	label.text = str(tile_data.position)
	label.position = tile_data.world_position + Vector2(5, 5)
	label.modulate = Color.BLACK
	add_child(label)
	
	# Store the visual reference
	tile_data.visual_indicator = marker

func create_tile_highlight():
	# Create a highlight that follows the mouse cursor
	tile_highlight = ColorRect.new()
	tile_highlight.color = Color(0, 1, 0, 0.3)  # Semi-transparent green
	tile_highlight.size = Vector2(TILE_WIDTH, TILE_HEIGHT)
	tile_highlight.visible = false
	add_child(tile_highlight)

func get_tile_at_position(pos: Vector2) -> Vector2i:
	var local_pos = pos - global_position - tile_origin
	var col = int(local_pos.x / TILE_WIDTH)
	var row = int(local_pos.y / TILE_HEIGHT)

	if col < 0 or col >= COLUMNS or row < 0 or row >= ROWS:
		return Vector2i(-1, -1)

	return Vector2i(col, row)

func get_world_position_from_tile(tile: Vector2i) -> Vector2:
	return global_position + tile_origin + Vector2(tile.x * TILE_WIDTH, tile.y * TILE_HEIGHT)

func update_tile_highlight(tile_pos: Vector2i):
	if tile_pos.x == -1 or tile_pos.y == -1:
		tile_highlight.visible = false
		return
		
	var tile_data = tiles.get(tile_pos)
	if tile_data:
		tile_highlight.position = tile_data.world_position
		tile_highlight.visible = true
		
		# Change color based on if placement is allowed
		if current_plant != null and tile_data.can_place_plant():
			tile_highlight.color = Color(0, 1, 0, 0.3)  # Green - can place
		else:
			tile_highlight.color = Color(1, 0, 0, 0.3)  # Red - cannot place

func place_plant(tile_pos: Vector2i, plant_type: String):
	if tile_pos.x == -1 or tile_pos.y == -1:
		return false
		
	var tile_data = tiles.get(tile_pos)
	if not tile_data or not tile_data.can_place_plant():
		return false
	
	# Create the plant instance
	var plant_instance = create_plant_instance(plant_type)
	if plant_instance:
		# Position the plant on the tile
		plant_instance.position = tile_data.world_position + Vector2(TILE_WIDTH/2, TILE_HEIGHT/2)
		plants_container.add_child(plant_instance)
		
		# Update tile data
		tile_data.place_plant(plant_instance)
		return true
	
	return false

func create_plant_instance(plant_type: String) -> Node2D:
	# This would load the appropriate plant scene based on type
	# For now, we'll create a placeholder
	var plant = Node2D.new()
	plant.name = plant_type
	
	# Add a visual representation (placeholder)
	var sprite = ColorRect.new()
	sprite.color = Color.GREEN
	sprite.size = Vector2(TILE_WIDTH * 0.8, TILE_HEIGHT * 0.8)
	sprite.position = -sprite.size / 2  # Center in the tile
	plant.add_child(sprite)
	
	# Add plant name label
	var label = Label.new()
	label.text = plant_type
	label.position = -Vector2(30, 20)
	label.modulate = Color.BLACK
	plant.add_child(label)
	
	return plant

func select_plant(plant_type: String):
	current_plant = plant_type
	print("Selected plant: ", plant_type)

func clear_plant_selection():
	current_plant = null
	tile_highlight.visible = false

func _process(delta):
	# Update tile highlight to follow mouse
	if current_plant != null:
		var mouse_pos = get_viewport().get_mouse_position()
		var tile = get_tile_at_position(mouse_pos)
		update_tile_highlight(tile)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		var tile = get_tile_at_position(event.position)
		var world_pos = get_world_position_from_tile(tile)
		
		if event.button_index == MOUSE_BUTTON_LEFT:
			if current_plant != null:
				if place_plant(tile, current_plant):
					print("Placed " + current_plant + " at tile: ", tile)
				else:
					print("Cannot place plant at tile: ", tile)
			elif developer_mode:
				print("Clicked tile: ", tile)
				
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			clear_plant_selection()
