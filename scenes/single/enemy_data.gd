
class_name EnemyData


class CardData:
	var id : int
	var name : String
	var short_name : String
	var ruby_name : String

	var color : int
	var level : int
	var power : int
	var hit : int
	var block : int
	var skills : Array
	var text : String
	var image : String


	func _init(i : int,n : String,sn : String,rn : String,
			c : int,l : int,p : int,h : int,b : int,
			s : Array,t : String,im : String):
		id = i
		name = n
		short_name = sn
		ruby_name = rn
		color = c
		level = l
		power= p
		hit = h
		block = b
		
		skills = s
		text = t
		image = im


var enemy_name : String

var hp : int

var deck_list : PoolIntArray # of index in card_list

var card_list : Array # of CardData

var skill_script : GDScript

var enemy_image : Texture

var card_images : Array # of Texture

func _init(folder : String):
	pass
	


