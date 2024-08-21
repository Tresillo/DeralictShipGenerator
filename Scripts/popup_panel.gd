extends Control

var text: String
@onready var label_node: RichTextLabel = $PanelContainer/MarginContainer/RichTextLabel


func set_text(txt: String):
	if not label_node:
		await self.ready
	label_node.text = txt
	
	var text_height = $PanelContainer/MarginContainer/RichTextLabel.get_content_height()
	custom_minimum_size = Vector2(custom_minimum_size.x, text_height)
