extends "res://scenes/ui/clickable_control.gd"

var card : Card
var o_position : Vector2
var o_z_index : int
var o_scale : Vector2
var o_rotation : float
var o_visible : bool
var o_parent_node : Node

func initialize(c:Card,p:Vector2,z:int,s:Vector2,r:float,v:bool,n:Node):
	card = c
	o_position = p
	o_z_index = z
	o_scale = s
	o_rotation = r
	o_visible = v
	o_parent_node = n


func _ready():
	pass
