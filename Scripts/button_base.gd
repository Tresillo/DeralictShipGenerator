@tool
extends TextureButton
class_name UIButtonBase

@export var icon: CompressedTexture2D:
	set(val):
		icon = val
		update_icon()
	get:
		return icon

@onready var icon_texture_node: TextureRect = $CenterContainer/IconTexture


func _ready():
	update_icon()


func update_icon():
	if icon_texture_node != null:
		icon_texture_node.texture = icon
	else:
		push_warning("Button could not find icon texture node.")


func _on_button_down():
	$CenterContainer.position = Vector2(2,2)
	if not $AudioStreams/ButtonDownSFX.playing:
		$AudioStreams/ButtonDownSFX.play()


func _on_button_up():
	$CenterContainer.position = Vector2(0,0)
	if not $AudioStreams/ButtonUpSFX.playing:
		$AudioStreams/ButtonUpSFX.play()
