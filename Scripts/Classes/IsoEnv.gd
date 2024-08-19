extends Node
class_name IsoEnv

var active_z_layer: int = 0
#{Vector3i: IsoObject}
var isometric_grid: Dictionary
#{int: Array[Vector2i] }
var available_positions: Dictionary

@onready var rng: RandomNumberGenerator = RandomNumberGenerator.new()

@export var die_sprites: Array[CompressedTexture2D]
@export var starting_dice: int = 8

const ISOGRIDSIZE: int = 37


func _ready():
	available_positions = {0: [Vector2i.ZERO]}


func isopos_to_isogrid_point(pos: IsoCoord) -> IsoCoord:
	var closest_grid_pos: Vector2 = Vector2.ZERO
	var vec_pos: Vector2 = Vector2(pos.x, pos.y)
	
	closest_grid_pos = round((vec_pos as Vector2) / float(ISOGRIDSIZE))
	
	var closest_isogrid_isopos = IsoCoord.new(closest_grid_pos.x, closest_grid_pos.y)
	
	return closest_isogrid_isopos


func grid_to_isocoord(grid_pos: Vector2i, z_layer: int = 0) -> IsoCoord:
	var relative_isocoord: IsoCoord = IsoCoord.new()
	
	relative_isocoord.x = (grid_pos.x + z_layer) * ISOGRIDSIZE
	relative_isocoord.y = (grid_pos.y - z_layer) * ISOGRIDSIZE
	
	return relative_isocoord


func update_available_locations(grid_coords: Vector3i):
	var free_dict_keys = available_positions.keys()
	var die_grid_keys = isometric_grid.keys()
	var z_layer = grid_coords.z
	
	var adding: bool = false
	if isometric_grid.keys().has(grid_coords):
		adding = true
	
	var coords_to_check = get_coordinate_neighbours(grid_coords)
	
	if not available_positions.keys().has(z_layer+1):
		available_positions[z_layer+1] = []
	if not available_positions.keys().has(z_layer-1):
		available_positions[z_layer-1] = []
	
	if adding:
		for chk in coords_to_check:
			#all coords in list must be either occupied or available
			if not (die_grid_keys.has(chk) or available_positions[chk.z].has(Vector2i(chk.x,chk.y))):
				available_positions[chk.z].append(Vector2i(chk.x,chk.y))
		if available_positions[z_layer].has(Vector2i(grid_coords.x, grid_coords.y)):
			available_positions[z_layer].erase(Vector2i(grid_coords.x, grid_coords.y))
	else: #deleting
		var cur_die_has_neighbour: bool = false
		for chk in coords_to_check:
			#coords need to be set to unavailable if not occupied, or neighbouring another tile.
			if not die_grid_keys.has(chk) and available_positions[chk.z].has(Vector2i(chk.x,chk.y)):
				#check if no occupied neighbours
				var neighbour_occupied: bool = false
				for i in get_coordinate_neighbours(chk):
					if die_grid_keys.has(i):
						neighbour_occupied = true
						break
				
				if not neighbour_occupied:
					available_positions[chk.z].erase(Vector2i(chk.x,chk.y))
			elif die_grid_keys.has(chk):
				cur_die_has_neighbour = true
		
		if cur_die_has_neighbour:
			available_positions[z_layer].append(Vector2i(grid_coords.x, grid_coords.y))
		
		if isometric_grid.is_empty():
			available_positions[0].append(Vector2i(0,0))


func get_coordinate_neighbours(grid_coords: Vector3i) -> Array:
	var neighbours = [Vector3i(grid_coords.x+1, grid_coords.y, grid_coords.z),
	Vector3i(grid_coords.x-1, grid_coords.y, grid_coords.z),
	Vector3i(grid_coords.x, grid_coords.y+1, grid_coords.z),
	Vector3i(grid_coords.x, grid_coords.y-1, grid_coords.z),
	Vector3i(grid_coords.x, grid_coords.y, grid_coords.z+1),
	Vector3i(grid_coords.x, grid_coords.y, grid_coords.z-1)]
	
	return neighbours


func get_iso_roll_anim_frames(num_of_frames: int, final_val: int) -> Array:
	var anim_frames:Array[CompressedTexture2D]
	var available_anim_frames:Array[CompressedTexture2D] = (die_sprites as Array).duplicate()
	available_anim_frames.remove_at(0)
	var remaining_frames:Array[CompressedTexture2D] = available_anim_frames.duplicate()
	
	#choose a series of different frames to animate through
	for i in range(num_of_frames-1):
		var new_frame = remaining_frames.pick_random()
		anim_frames.append(new_frame)
		remaining_frames.clear()
		remaining_frames = available_anim_frames.duplicate()
		remaining_frames.erase(new_frame)
	
	#make sure it ends on the correct frame
	anim_frames.append(anim_frames[final_val])
	
	return anim_frames
