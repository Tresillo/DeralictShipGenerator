extends CenterContainer
class_name DiceItem

@export var roll_frame_speed: float = 0.1
@export var roll_frames: int = 12

var die_value: int
var ui_controller_node: CanvasLayer

@onready var isoenv_node: IsoEnv = get_node("/root/GlobalIsoEnv")

signal clicked(obj: DiceItem)
signal deleting


func _on_display_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			clicked.emit(self)


func _on_minus_button_button_down():
	ui_controller_node.tray_item_last_added = false
	deleting.emit()
	queue_free()


func update_display_val(new_val: int):
	die_value = new_val
	$MarginContainer/Display.texture = isoenv_node.die_sprites[new_val]


func roll_anim():
	var new_val = isoenv_node.rng.randi_range(1,6)
	var anim_frames = isoenv_node.get_iso_roll_anim_frames(roll_frames, new_val)
	#reverse array as popping back is faster than popping front
	anim_frames.reverse()
	
	var roll_anim = get_tree().create_tween().bind_node(self)
	
	for i in anim_frames:
		var next_frame = anim_frames.pop_back()
		roll_anim.tween_callback(func(): $MarginContainer/Display.texture = next_frame)
		if anim_frames.size()>0:
			roll_anim.tween_interval(roll_frame_speed)
