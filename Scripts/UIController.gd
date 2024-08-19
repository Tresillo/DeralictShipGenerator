extends CanvasLayer

var tray_closed: bool = false
var tray_closed_pos_offset: Vector2
var tray_movement_tween: Tween

@onready var isoenv_node: IsoEnv = get_node("/root/GlobalIsoEnv")
var dice_object_prefab: PackedScene = preload("res://Prefabs/dice_item.tscn")

var dice_item_container: VBoxContainer
var tray_scroll_container: ScrollContainer
var tray_item_last_added: bool = false

var store_all_enabled: bool = true
var place_all_enabled: bool = true

var clicked_dice

signal item_clicked(dice)


func _ready():
	tray_closed_pos_offset = Vector2($TabTray/ClosedAnchor.position.x * -1, 0)
	($TabTray/TabButton as BaseButton).button_down.connect(func(): change_tray_state(not tray_closed))
	dice_item_container = $TabTray/MarginContainer/VBoxContainer/Dice/ScrollContainer/VBoxContainer/DiceContainer
	tray_scroll_container = $TabTray/MarginContainer/VBoxContainer/Dice/ScrollContainer
	tray_scroll_container.get_v_scroll_bar().changed.connect(handle_new_item_scroll)
	
	clicked_dice = null
	store_all_enabled = true
	place_all_enabled = true


func change_tray_state(new_state: bool):
	print(new_state)
	if tray_movement_tween is Tween and tray_movement_tween.is_running():
		tray_movement_tween.kill()
	
	tray_movement_tween = get_tree().create_tween().bind_node(self).set_ease(Tween.EASE_IN_OUT)
	var new_pos: Vector2 = Vector2(0,0)
	if new_state:
		new_pos = tray_closed_pos_offset
	
	tray_movement_tween.tween_property($TabTray, "position", new_pos, 0.3).set_trans(Tween.TRANS_QUAD)
	tray_closed = new_state


func _on_add_dice_button_button_down():
	#print("add button pressed")
	var new_val: int = isoenv_node.rng.randi_range(1,6)
	add_die_to_tray(new_val)
	if not $AudioStreams/ButtonDownSFX.playing:
		$AudioStreams/ButtonDownSFX.play()


func add_die_to_tray(val: int):
	tray_item_last_added = true
	var new_obj = dice_object_prefab.instantiate()
	dice_item_container.add_child(new_obj)
	new_obj.ui_controller_node = self
	new_obj.update_display_val(val)
	new_obj.clicked.connect(dice_clicked)
	new_obj.deleting.connect(_play_destroy_sound)


func _play_destroy_sound():
	print("hi")
	if not $AudioStreams/RemoveDieItemSFX.playing:
		$AudioStreams/RemoveDieItemSFX.play()


func handle_new_item_scroll():
	if tray_item_last_added:
		#scroll container scroll to bottom
		var max_val = tray_scroll_container.get_v_scroll_bar().max_value
		var target_scroll = max(max_val - tray_scroll_container.size.y, 0)
		tray_scroll_container.scroll_vertical =  max_val


func dice_clicked(clicked_item: DiceItem):
	clicked_item.visible = false
	clicked_dice = clicked_item
	item_clicked.emit(clicked_item)


func _on_roll_all_button_button_up():
	print("play roll sound")
	get_tree().call_group("rollable", "roll_anim")


func _on_store_button_button_up():
	if store_all_enabled:
		get_parent().store_all_iso_objects()


func _on_place_all_button_button_up():
	if place_all_enabled:
		get_parent().place_all_tray_dice()


func _on_add_dice_button_button_up():
	if not $AudioStreams/ButtonUpSFX.playing:
		$AudioStreams/ButtonUpSFX.play()
