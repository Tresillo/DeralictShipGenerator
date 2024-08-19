extends Node
class_name DiceRollTables

@export var tables: Array[RollTable]

@onready var rng: RandomNumberGenerator = RandomNumberGenerator.new()


func roll_module(table: int) -> Dictionary:
	var t_ind = clampi(table, 1, 6)
	
	var result = tables[t_ind-1].roll(rng)
	
	return result
