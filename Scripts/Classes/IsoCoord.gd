extends  Resource
class_name IsoCoord

@export var x: float = 0
@export var y: float = 0

const _SINE30: float = 0.5
const _COS30: float = 0.8660254


func _init(m_x: float = 0, m_y: float = 0):
	x = m_x
	y = m_y

#creates a set of Isocoords from a generic Vector2
func from_vec2(m_coord: Vector2) -> IsoCoord:
	var temp_x = m_coord.x
	var temp_y = m_coord.y
	return IsoCoord.new(temp_x,temp_y)


func to_vec2() -> Vector2:
	return Vector2(x,y)


func to_vec2i() -> Vector2i:
	return Vector2i(int(x),int(y))


#Figures out the isometric coordinates from a given position
func from_position(m_pos: Vector2) -> IsoCoord:
	var temp_position = IsoCoord.new()
	
	var de_trig_x:float = float(m_pos.x) / _COS30
	var de_trig_y:float = float(m_pos.y) / _SINE30
	
	temp_position.x = de_trig_x - de_trig_y
	temp_position.y = de_trig_y + de_trig_x
	
	return temp_position


#Converts the Isometric Grid to the Godot 2D grid
func to_position() -> Vector2:
	var IsoPos: Vector2 = Vector2.ZERO
	IsoPos.x = (x + y) * _COS30
	IsoPos.y = (y - x) * _SINE30
	return IsoPos
