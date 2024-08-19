extends Camera2D

@export var pan_sensitivity: float = 1.1
@export var zoom_sensitivity: float = 0.2
@export var zoom_bounds_min: float = 0.5
@export var zoom_bounds_max: float = 4.0

@export var grid_node: Node2D

@onready var isoenv_node: IsoEnv = get_node("/root/GlobalIsoEnv")

var panning: bool = false
var current_zoom: Vector2

var last_pan_mouse_pos: Vector2
var target_pos = Vector2()


func _ready():
	current_zoom = zoom
	target_pos = position


func _process(delta):
	if not zoom.is_equal_approx(current_zoom):
		zoom = lerp(zoom, current_zoom, 0.5)
	else:
		zoom = current_zoom
	
	if not position.is_equal_approx(target_pos):
		position = lerp(position, target_pos, 0.8)
	else:
		position = target_pos
	
	if abs(position.distance_to(grid_node.position)) > isoenv_node.ISOGRIDSIZE*2:
		#snapping code from the placing ghost
		var bg_iso_coord: IsoCoord = IsoCoord.new().from_position(position*0.5)
		var bg_grid: IsoCoord = isoenv_node.isopos_to_isogrid_point(bg_iso_coord)
		var bg_grid_coord: IsoCoord = isoenv_node.grid_to_isocoord(Vector2i(bg_grid.x, bg_grid.y))
		grid_node.position = bg_grid_coord.to_position()


func _unhandled_input(event):
	if get_tree().paused == false:
		if event.is_action_pressed("cam_pan"):
			panning = true
			last_pan_mouse_pos = get_parent().get_local_mouse_position()
		
		if event.is_action_released("cam_pan"):
			panning = false
		
		if event.is_action_pressed("cam_zoom_in"):
			var new_zoom = max(zoom_bounds_min, current_zoom.x - zoom_sensitivity*current_zoom.x)
			current_zoom = Vector2(new_zoom,new_zoom)
		
		if event.is_action_pressed("cam_zoom_out"):
			var new_zoom = min(zoom_bounds_max, current_zoom.x + zoom_sensitivity*current_zoom.x)
			current_zoom = Vector2(new_zoom,new_zoom)
