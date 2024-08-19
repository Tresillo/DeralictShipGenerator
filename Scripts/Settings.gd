extends PanelContainer

@export var cam_node: Camera2D

@onready var isoenv_node: IsoEnv = get_node("/root/GlobalIsoEnv")

var reset_confirming: bool = false


func _ready():
	$MarginContainer/VBoxContainer/StartingDice/SpinBox.value = isoenv_node.starting_dice


func _unhandled_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton or event is InputEventKey) and reset_confirming:
		reset_confirming = false
		$MarginContainer/VBoxContainer/ResetButton.text = "      Reset      "


func _on_spin_box_value_changed(value: float) -> void:
	isoenv_node.starting_dice = roundi(value)


func _on_button_button_down() -> void:
	if not $AudioStreams/ButtonDownSFX.playing:
		$AudioStreams/ButtonDownSFX.play()


func _button_release() -> void:
	if not $AudioStreams/ButtonUpSFX.playing:
		$AudioStreams/ButtonUpSFX.play()


func _on_reset_cam_button_button_up() -> void:
	cam_node.position = Vector2.ZERO
	cam_node.target_pos = Vector2.ZERO
	_button_release()


func _on_reset_button_button_up() -> void:
	_button_release()
	if not reset_confirming:
		reset_confirming = true
		$MarginContainer/VBoxContainer/ResetButton.text = "  Are You Sure?  "
	else:
		call_deferred("_unpause")
		get_tree().call_deferred("reload_current_scene")


func _on_back_button_button_up() -> void:
	#$AudioStreams/ButtonDownSFX.stop()
	#$AudioStreams/ButtonUpSFX.stop()
	call_deferred("_unpause")
	visible = false
	position = Vector2(0, 2400)


func _unpause():
	get_tree().paused = false
