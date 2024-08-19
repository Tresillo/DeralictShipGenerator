extends Resource
class_name RollTable

@export var entries: Array[String] = ["","","","","","","","","",""]
@export var descriptions: Array[String] = ["","","","","","","","","",""]
@export var sub_roles: Array[int] = [0,0,0,0,0,0,0,0,0,0]
@export var sub_role_units: Array[String] = ["","","","","","","","","",""]
@export var sub_tables: Array[RollTable] = [null,null,null,null,null,null,null,null,null,null]


func _init():
	if entries.is_empty():
		entries.resize(10)
	descriptions.resize(entries.size())
	sub_tables.resize(entries.size())

#RETURNS:
# "title":		type of room							:String
# "detail":		description of room						:String
# "sub_roll":	description of random variance in room	:String
# "sub_table":	sub table rolled for room				:Dictionary
func roll(rng: RandomNumberGenerator) -> Dictionary:
	if entries.is_empty() or descriptions.is_empty():
		return {}
	
	var index = rng.randi_range(0,entries.size()-1)
	var results:Dictionary = {"rolled_value": index,
					"title": entries[index],
					"detail": descriptions[index]}
	
	if sub_roles[index] > 0:
		var roll_result
		var val = rng.randi_range(1,sub_roles[index])
		if sub_role_units[index] != "" and sub_role_units[index] != null:
			results["sub_role"] = str(val) + " " + sub_role_units[index]
		else:
			results["sub_role"] = str(val)
	else:
		results["sub_role"] = null
	
	var rolled_table = sub_tables[index]
	if rolled_table != null and rolled_table is RollTable:
		results["sub_table"] = rolled_table.roll(rng)
	else:
		results["sub_table"] = null
	
	return results
