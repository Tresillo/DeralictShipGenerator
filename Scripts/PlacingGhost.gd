extends Node2D
class_name PlacingGhost

@export var display_coords: IsoCoord
@export var follower_position: Vector2
@export var snap_distance: int = 80
@export var snap_mult: float = 1.0

@onready var isoenv_node: IsoEnv = get_node("/root/GlobalIsoEnv")

enum DRAGTYPE {NONE, FIELD, UI}
var dragging: DRAGTYPE = DRAGTYPE.NONE

var display_grid_coords: Vector2i
var holding_die: bool = false
var holding_grid_coords: Vector2i
var holding_num: int = 0
var holding_roll_results: Dictionary = {}
var last_mouse_pos: Vector2


func _ready():
	last_mouse_pos = get_global_mouse_position()
	z_index = 0
	$MouseFollower.z_index = 100
	holding_grid_coords = Vector2.ZERO
	dragging = DRAGTYPE.NONE


func _process(delta):
	var cur_mouse_pos = get_global_mouse_position()
	if visible and last_mouse_pos != cur_mouse_pos:
		snap(cur_mouse_pos)
		$MouseFollower.global_position = get_global_mouse_position()
		last_mouse_pos = cur_mouse_pos


func snap(mouse_pos: Vector2):
	var mouse_iso_coord: IsoCoord = IsoCoord.new().from_position(mouse_pos * 0.5)
	var mouse_grid: IsoCoord = isoenv_node.isopos_to_isogrid_point(mouse_iso_coord)
	var mouse_grid_coord: IsoCoord = isoenv_node.grid_to_isocoord(Vector2i(mouse_grid.x, mouse_grid.y))
	
	$PlacingDisplay.z_index = mouse_grid_coord.y - mouse_grid_coord.x
	$MouseFollower.z_index = $PlacingDisplay.z_index + 1
	
	var available_grid_pos = isoenv_node.available_positions[isoenv_node.active_z_layer]
	var closest_grid_pos: Vector2i
	var shortest_dist: float = -1
	
	var cur_snap_dist = snap_distance * snap_distance * snap_mult * snap_mult
	if available_grid_pos.size() <= 1:
		cur_snap_dist *= 5
	
	for crd in available_grid_pos:
		var grid_crd_pos = isoenv_node.grid_to_isocoord(crd).to_position()
		var gcp_dist_sqrd = mouse_pos.distance_squared_to(grid_crd_pos)
		if gcp_dist_sqrd < (snap_distance * snap_mult * snap_distance * snap_mult):
			#can snap to, now look for if its the closest snap point
			if gcp_dist_sqrd < shortest_dist or shortest_dist < 0:
				#if its the closest so far, save a reference to it
				shortest_dist = gcp_dist_sqrd
				closest_grid_pos = crd
		
		#if a relavant snap point is found, display it
		if shortest_dist >= 0:
			position = isoenv_node.grid_to_isocoord(closest_grid_pos).to_position()
			display_grid_coords = closest_grid_pos
			$MouseFollower.visible = false
			$PlacingDisplay.visible = true
		else:
			position = mouse_pos
			display_grid_coords = Vector2i.ZERO
			$MouseFollower.visible = true
			$PlacingDisplay.visible = false

func update_dice_display(dice_num: int):
	var die_sprite = isoenv_node.die_sprites[dice_num]
	holding_num = dice_num
	$PlacingDisplay.texture = die_sprite
	$MouseFollower.texture = die_sprite
