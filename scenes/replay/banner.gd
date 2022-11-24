extends Control

class_name ReplayBanner


var match_log : MatchLog

func initialize(match_log : MatchLog):
	self.match_log = match_log
	
	$LabelPlayer1.text = match_log.primary_data.my_name
	$LabelPlayer2.text = match_log.primary_data.rival_name
	$LabelRegulation.text = match_log.primary_data.regulation

func _ready():
	pass
