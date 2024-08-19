extends Node2D
class_name IsoObject

var coords: IsoCoord
@export var isogrid_pos: Vector2i
@export var z_layer: int
@export var roll_frame_speed: float = 0.1
@export var roll_frames: int = 12
@export var place_anim_time: float = 0.3
@export var place_anim_dist: float = -10

@onready var isoenv_node: IsoEnv = get_node("/root/GlobalIsoEnv")

var grid_size: int
var die_value: int
var roll_tween: Tween
var place_tween: Tween

var roll_table_results: Dictionary


func _ready():
	coords = IsoCoord.new()
	grid_size = isoenv_node.ISOGRIDSIZE
	
	z_layer = 0
	($Sprite2D as Sprite2D).z_index = z_layer
	#update_iso_grid_pos(isogrid_pos)
	
	#lil place animation for JUICE(tm)
	place_tween = get_tree().create_tween().bind_node(self)\
			.set_trans(Tween.TRANS_BACK)\
			.set_ease(Tween.EASE_IN)
	place_tween.tween_callback(func(): $Sprite2D.position = Vector2(0, place_anim_dist))
	place_tween.tween_property($Sprite2D,"position", Vector2.ZERO, place_anim_time)
	#place_tween.tween_callback(func(): print("place sound"))


func _process(delta):
	position = coords.to_position()


func add_to_grid(new_grid_pos: Vector2i, new_z_layer: int):
	isogrid_pos = new_grid_pos
	z_layer = new_z_layer
	update_iso_grid_pos(new_grid_pos)
	
	isoenv_node.isometric_grid[Vector3i(isogrid_pos.x,isogrid_pos.y,z_layer)] = self
	isoenv_node.update_available_locations(Vector3i(new_grid_pos.x, new_grid_pos.y, new_z_layer))


func remove_from_grid():
	var grid_key = Vector3i(isogrid_pos.x,isogrid_pos.y,z_layer)
	isoenv_node.isometric_grid.erase(grid_key)
	isoenv_node.update_available_locations(grid_key)


func update_iso_grid_pos(new_grid_pos: Vector2i):
	coords.x = new_grid_pos.x * grid_size
	coords.y = new_grid_pos.y * grid_size
	
	isogrid_pos = new_grid_pos
	
	z_index = new_grid_pos.y - new_grid_pos.x


func update_display_val(new_val: int):
	var die_sprite = isoenv_node.die_sprites[new_val]
	$Sprite2D.texture = die_sprite
	die_value = new_val


func roll_anim():
	
	if place_tween is Tween and place_tween.is_running():
		place_tween.kill()
		$Sprite2D.position = Vector2.ZERO
	
	$RolltableTitle.visible = false
	$RolltableTitle.text = ""
	roll_table_results = {}
	
	var new_val = isoenv_node.rng.randi_range(1,6)
	var anim_frames = isoenv_node.get_iso_roll_anim_frames(roll_frames, new_val)
	#reverse array as popping back is faster than popping front
	anim_frames.reverse()
	
	var roll_anim = get_tree().create_tween().bind_node(self)
	
	for i in anim_frames:
		var next_frame = anim_frames.pop_back()
		roll_anim.tween_callback(func(): $Sprite2D.texture = next_frame)
		if anim_frames.size()>0:
			roll_anim.tween_interval(roll_frame_speed)


func update_roll_table(new_roll: Dictionary):
	roll_table_results = new_roll
	
	$RolltableTitle.text = roll_table_results["title"]
	$RolltableTitle.visible = true
