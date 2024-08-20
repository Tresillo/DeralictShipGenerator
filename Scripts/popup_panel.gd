extends Control

var text: String
@onready var label_node: RichTextLabel = $PanelContainer/MarginContainer/RichTextLabel


func set_text(txt: String):
	if not label_node:
		await self.ready
	label_node.text = txt


func set_text_from_dict(die_res: Dictionary):
	if not label_node:
		await self.ready
	
	pass
