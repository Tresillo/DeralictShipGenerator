extends TextureRect

@onready var tooltip_prefab = preload("res://Prefabs/popup_panel.tscn")

var roll_table_results: Dictionary:
	set(val):
		roll_table_results = val
		update_tooltip(roll_table_results)
	get:
		return roll_table_results


func _ready() -> void:
	tooltip_text = ""


func update_tooltip(new_roll: Dictionary):
	
	if new_roll != {}:
		var updated_tooltip = "[center]" + str(new_roll["title"]) + "[/center]\n" +\
				str(new_roll["detail"])
		
		if new_roll["sub_role"] != null:
			updated_tooltip += " || " + str(new_roll["sub_role"])
		
		if new_roll["sub_table"] != null:
			updated_tooltip += " || " + str(new_roll["sub_table"])
		
		tooltip_text = updated_tooltip
	
	else:
		tooltip_text = ""


func _make_custom_tooltip(for_text: String) -> Object:
	var tooltip = tooltip_prefab.instantiate()
	tooltip.set_text(for_text)
	return tooltip
