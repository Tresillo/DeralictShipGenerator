extends Node2D

@export var placing_ghost: PlacingGhost
@export var roll_tables: DiceRollTables
@export var camera: Camera2D
@export var origin_rect: TextureRect

@onready var isoenv_node: IsoEnv = get_node("/root/GlobalIsoEnv")
@onready var iso_object_prefab = preload("res://Prefabs/iso_object.tscn")

var iso_objects: Array

var left_button_clicked:bool = false
var right_button_clicked: bool = false

var placing: bool = false
var can_place: bool = true

var isogrid_size: int


func _ready():
	#print(test_object.get_child(0).get_rect())
	placing = false
	isogrid_size = isoenv_node.ISOGRIDSIZE
	
	#add starting
	for i in range(isoenv_node.starting_dice):
		$UI.add_die_to_tray(isoenv_node.rng.randi_range(1,6))
	$UI.tray_scroll_container.set_deferred("scroll_vertical", 0)


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			left_button_clicked = true
		
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			right_button_clicked = true
	
	if event is InputEventMouseMotion and camera.panning == true:
		var mouse_pos_delta = get_local_mouse_position() - camera.last_pan_mouse_pos
		camera.target_pos -= mouse_pos_delta * camera.pan_sensitivity
		camera.last_pan_mouse_pos = get_local_mouse_position()


func _physics_process(delta):
	#rising edge
	if left_button_clicked and not placing and can_place:
		left_button_clicked = false
		
		var clicked_object = test_mouse_for_iso_objects()
		
		if clicked_object != null and clicked_object is IsoObject:
			clicked_object.remove_from_grid()
			placing_ghost.dragging = placing_ghost.DRAGTYPE.FIELD
			placing_ghost.holding_grid_coords = clicked_object.isogrid_pos
			placing_ghost.holding_roll_results = clicked_object.roll_table_results
			placing = true
			placing_ghost.update_dice_display(clicked_object.die_value)
			placing_ghost.visible = true
			clicked_object.queue_free()
	elif left_button_clicked and not placing and not can_place:
		left_button_clicked = false
	
	
	#rising edge for placing
	elif left_button_clicked and placing and can_place:
		#print("placed")
		placing = false
		left_button_clicked = false
		var placing_grid_coords = placing_ghost.display_grid_coords
		
		if isoenv_node.available_positions[isoenv_node.active_z_layer].has(placing_grid_coords):
			var new_die = iso_object_prefab.instantiate()
			$GridLayer.add_child(new_die)
			new_die.add_to_grid(Vector2i(placing_grid_coords.x, placing_grid_coords.y), isoenv_node.active_z_layer)
			isoenv_node.update_available_locations(
					Vector3i(placing_grid_coords.x, placing_grid_coords.y, isoenv_node.active_z_layer))
			
			new_die.update_display_val(placing_ghost.holding_num)
			new_die.roll_table_results = placing_ghost.holding_roll_results
			placing_ghost.holding_roll_results = {}
			die_place_sound()
			
			#Fully remove dice ui item if the dice isnt being relocated
			if placing_ghost.dragging == placing_ghost.DRAGTYPE.UI:
				$UI.clicked_dice.queue_free()
				$UI.clicked_dice = null
			else:
				placing_ghost.holding_grid_coords = Vector2i.ZERO
		elif left_button_clicked and placing and not can_place:
			left_button_clicked = false
		
		else:
			if placing_ghost.dragging == placing_ghost.DRAGTYPE.UI:
				$UI.clicked_dice.visible = true
				$UI.clicked_dice = null
				die_store_sound()
			else:
				#create a new tray die if one is being relocated and dropped
				$UI.add_die_to_tray(placing_ghost.holding_num)
				placing_ghost.holding_grid_coords = Vector2i.ZERO
		
		#reset placing ghost
		placing_ghost.holding_num = 0
		placing_ghost.visible = false
		placing_ghost.dragging = placing_ghost.DRAGTYPE.NONE
	
	
	elif right_button_clicked and placing:
		right_button_clicked = false
		placing_ghost.visible = false
		placing = false
		
		if placing_ghost.dragging == placing_ghost.DRAGTYPE.UI:
			$UI.clicked_dice.visible = true
			$UI.clicked_dice = null
			die_store_sound()
		else:
			#canceling moving a die from the field
			var new_die = iso_object_prefab.instantiate()
			$GridLayer.add_child(new_die)
			new_die.add_to_grid(placing_ghost.holding_grid_coords, isoenv_node.active_z_layer)
			isoenv_node.update_available_locations(
					Vector3i(placing_ghost.holding_grid_coords.x,\
							placing_ghost.holding_grid_coords.y,\
							isoenv_node.active_z_layer))
			
			new_die.update_display_val(placing_ghost.holding_num)
		
		placing_ghost.holding_num = 0
		placing_ghost.visible = false
		placing_ghost.display_grid_coords = Vector2i.ZERO
		
		placing_ghost.dragging = placing_ghost.DRAGTYPE.NONE


func test_mouse_for_iso_objects() -> IsoObject:
	var space_state = get_world_2d().direct_space_state
	
	var params = PhysicsPointQueryParameters2D.new()
	params.position = get_global_mouse_position()
	params.collide_with_areas = true
	params.collide_with_bodies = false
	params.collision_mask = 1
	
	var results = space_state.intersect_point(params)
	#print(results)
	
	var clicked_object = null
	var clicked_z_index: int = -999
	if results.size() > 0:
		for r in results:
			var temp_obj = r["collider"].get_parent()
			if temp_obj.z_index > clicked_z_index and temp_obj.z_layer == isoenv_node.active_z_layer:
				clicked_object = temp_obj
				clicked_z_index = temp_obj.z_layer
	return clicked_object


func _on_ui_item_clicked(dice):
	placing = true
	placing_ghost.visible = true
	placing_ghost.dragging = placing_ghost.DRAGTYPE.UI
	placing_ghost.update_dice_display(dice.die_value)


func _process(delta):
	if $GridLayer.get_children().size() > 0:
		origin_rect.visible = false
	else:
		origin_rect.visible = true


func _on_roll_tables_button_up():
	for t in $GridLayer.get_children():
		if t is IsoObject:
			t.update_roll_table(roll_tables.roll_module(t.die_value))


func store_all_iso_objects():
	var grid_dice = $GridLayer.get_children()
	if grid_dice.size() > 0:
		$UI.store_all_enabled = false
		$UI.place_all_enabled = false
		for d in grid_dice:
			if d != null and d is IsoObject:
				#remove from grid
				d.remove_from_grid()
				var temp_die_value = d.die_value
				#var temp_holding_grid_coords = d.isogrid_pos
				#var temp_holding_roll_results = d.roll_table_results
				d.queue_free()
				die_store_sound()
				
				#add to sidebar
				$UI.add_die_to_tray(temp_die_value)
				await get_tree().create_timer(0.09).timeout
		
		$UI.store_all_enabled = true
		$UI.place_all_enabled = true


func place_all_tray_dice():
	var dice_items = %DiceContainer.get_children()
	if dice_items.size() > 2:
		$UI.place_all_enabled = false
		$UI.store_all_enabled = false
		var place_poses = isoenv_node.available_positions[isoenv_node.active_z_layer]
		for i in dice_items:
			if i != null and i is DiceItem:
				#find random avaibale location
				var rand_ind = isoenv_node.rng.randi_range(0, place_poses.size()-1)
				var temp_pos = place_poses[rand_ind]
				
				#add new iso object
				var new_die = iso_object_prefab.instantiate()
				$GridLayer.add_child(new_die)
				new_die.add_to_grid(Vector2i(temp_pos.x, temp_pos.y), isoenv_node.active_z_layer)
				isoenv_node.update_available_locations(
						Vector3i(temp_pos.x, temp_pos.y, isoenv_node.active_z_layer))
				
				new_die.update_display_val(i.die_value)
				die_place_sound()
				
				#remove dice item from list
				i.visible = false
				i.queue_free()
				
				#small delay for cool factor :)
				await get_tree().create_timer(0.09).timeout
		
		$UI.place_all_enabled = true
		$UI.store_all_enabled = true


func die_place_sound():
	$AudioStreams/PlacingSFX.play()


func die_store_sound():
	$AudioStreams/StoringSFX.play()
