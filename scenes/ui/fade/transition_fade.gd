# warning-ignore-all:return_value_discarded

tool

extends TextureRect

class_name TransitionFade


signal fade_finished

export(float,0.0,1.0) var rate : float setget rate_setter
func rate_setter(v):
	rate = v
	if material and material is ShaderMaterial:
		set_rate(v)

export(Texture) var rule : Texture setget rule_setter
func rule_setter(v):
	rule = v
	if material and material is ShaderMaterial:
		var sm = material as ShaderMaterial
		sm.set_shader_param("rule",v)

export(bool) var invert : bool setget invert_setter
func invert_setter(v):
	invert = v
	if material and material is ShaderMaterial:
		var sm = material as ShaderMaterial
		sm.set_shader_param("invert",v)


var tween : SceneTreeTween

func _ready():
	var sm = ShaderMaterial.new()
	sm.shader = preload("transition_fade.gdshader")
	sm.set_shader_param("rule", rule)
	sm.set_shader_param("invert",invert)
	material = sm
	pass

func set_rate(r):
	material.set_shader_param("rate",r)

func fade_out(duration : float):
	if material and material is ShaderMaterial:
		tween = create_tween()
		tween.tween_method(self,"set_rate",0.0,1.0,duration)
		tween.connect("finished",self,"tween_finished",[],CONNECT_ONESHOT)

func fade_in(duration : float):
	if material and material is ShaderMaterial:
		tween = create_tween()
		tween.tween_method(self,"set_rate",1.0,0.0,duration)
		tween.connect("finished",self,"tween_finished",[],CONNECT_ONESHOT)

func tween_finished():
	emit_signal("fade_finished")

func cancel_fade(force_rate : float):
	if tween and tween.is_running():
		tween.stop()
		set_rate(force_rate)
#		emit_signal("fade_finished")
