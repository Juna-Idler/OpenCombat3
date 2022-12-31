tool

# warning-ignore-all:return_value_discarded

extends Control

class_name RubyLabel, "icon.png"

func _get_property_list():
	var properties = [
		{
			name = "RubyLabel",
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		{
			name = "Font",
			type = TYPE_NIL,
			hint_string = "font_",
			usage = PROPERTY_USAGE_GROUP | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		{
			name = "font_font",
			type = TYPE_OBJECT,hint = PROPERTY_HINT_RESOURCE_TYPE,hint_string = "Font"
		},
		{
			name = "font_ruby_font",
			type = TYPE_OBJECT,hint = PROPERTY_HINT_RESOURCE_TYPE,hint_string = "Font"
		},
		{
			name = "font_color",
			type = TYPE_COLOR,
		},
		{
			name = "font_outline_color",
			type = TYPE_COLOR,
		},
		{
			name = "RubyAlignment",
			type = TYPE_NIL,
			hint_string = "ruby_alignment_",
			usage = PROPERTY_USAGE_GROUP | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		{
			name = "ruby_alignment_ruby",
			type = TYPE_INT,hint = PROPERTY_HINT_ENUM ,hint_string = PoolStringArray(RubyAlignment.keys()).join(",")
		},
		{
			name = "ruby_alignment_parent",
			type = TYPE_INT,hint = PROPERTY_HINT_ENUM ,hint_string = PoolStringArray(ParentAlignment.keys()).join(",")
		},
		{
			name = "Buffer",
			type = TYPE_NIL,
			hint_string = "buffer_",
			usage = PROPERTY_USAGE_GROUP | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		{
			name = "buffer_left_margin",
			type = TYPE_INT,hint = PROPERTY_HINT_RANGE ,hint_string = "0,1024,or_greater"
		},
		{
			name = "buffer_right_margin",
			type = TYPE_INT ,hint = PROPERTY_HINT_RANGE ,hint_string = "0,1024,or_greater"
		},
		{
			name = "buffer_left_padding",
			type = TYPE_INT,hint = PROPERTY_HINT_RANGE ,hint_string = "0,1024,or_greater"
		},
		{
			name = "buffer_right_padding",
			type = TYPE_INT,hint = PROPERTY_HINT_RANGE ,hint_string = "0,1024,or_greater"
		},
		{
			name = "buffer_visible_border",
			type = TYPE_BOOL,
		},
		{
			name = "Adjust",
			type = TYPE_NIL,
			hint_string = "adjust_",
			usage = PROPERTY_USAGE_GROUP | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		{
			name = "adjust_line_height",
			type = TYPE_INT,hint = PROPERTY_HINT_RANGE ,hint_string = "-256,256,or_lesser,or_greater"
		},
		{
			name = "adjust_ruby_distance",
			type = TYPE_INT,hint = PROPERTY_HINT_RANGE ,hint_string = "-256,256,or_lesser,or_greater"
		},
		{
			name = "adjust_no_ruby_space",
			type = TYPE_INT,hint = PROPERTY_HINT_RANGE ,hint_string = "-256,256,or_lesser,or_greater"
		},
		{
			name = "Text",
			type = TYPE_NIL,
			hint_string = "text_",
			usage = PROPERTY_USAGE_GROUP | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		{
			name = "text_input",
			type = TYPE_STRING,hint = PROPERTY_HINT_MULTILINE_TEXT,
		},
		{
			name = "text_ruby_parent",
			type = TYPE_STRING,
		},
		{
			name = "text_ruby_begin",
			type = TYPE_STRING,
		},
		{
			name = "text_ruby_end",
			type = TYPE_STRING,
		},
		{
			name = "Display",
			type = TYPE_NIL,
			hint_string = "display_",
			usage = PROPERTY_USAGE_GROUP | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		{
			name = "display_horizontal_alignment",
			type = TYPE_INT,hint = PROPERTY_HINT_ENUM,hint_string = PoolStringArray(HorizontalAlignment.keys()).join(",")
		},
		{
			name = "display_vertical_alignment",
			type = TYPE_INT,hint = PROPERTY_HINT_ENUM,hint_string = PoolStringArray(VerticalAlignment.keys()).join(",")
		},
		{
			name = "display_rate",
			type = TYPE_REAL,hint = PROPERTY_HINT_RANGE ,hint_string = "0,100"
		},
		{
			name = "display_rate_phonetic",
			type = TYPE_BOOL,
		},
		{
			name = "Output",
			type = TYPE_NIL,
			hint_string = "output_",
			usage = PROPERTY_USAGE_GROUP | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		{
			name = "output_base_text",
			type = TYPE_STRING,hint = PROPERTY_HINT_MULTILINE_TEXT,
		},
		{
			name = "output_phonetic_text",
			type = TYPE_STRING,hint = PROPERTY_HINT_MULTILINE_TEXT,
		},
		{
			name = "Other",
			type = TYPE_NIL,
			hint_string = "",
			usage = PROPERTY_USAGE_GROUP | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		{
			name = "clip_rect",
			type = TYPE_BOOL,
		},
		{
			name = "auto_fit_height",
			type = TYPE_BOOL,
		},		
	]
	return properties


func font_changed():
#	font_font.update_changes()
#	font_ruby_font.update_changes()
	build_words()

var font_font : DynamicFont setget font_font_setter
func font_font_setter(v):
	font_font = v
	if font_font:
		font_font.connect("changed",self,"font_changed")
	build_words()
var font_ruby_font : DynamicFont setget font_ruby_font_setter
func font_ruby_font_setter(v):
	font_ruby_font = v
	if font_ruby_font:
		font_ruby_font.connect("changed",self,"font_changed")
	build_words()

var font_color : Color = Color.white setget font_color_setter
func font_color_setter(v):
	font_color = v
	update()
var font_outline_color : Color = Color.black setget font_outline_color_setter
func font_outline_color_setter(v):
	font_outline_color = v
	update()


enum RubyAlignment {CENTER,SPACE121,SPACE010}
var ruby_alignment_ruby  : int setget ruby_alignment_ruby_setter
func ruby_alignment_ruby_setter(v):
	ruby_alignment_ruby = v
	build_words()

enum ParentAlignment {NOTHING,CENTER,SPACE121,SPACE010}
var ruby_alignment_parent  : int setget ruby_alignment_parent_setter
func ruby_alignment_parent_setter(v):
	ruby_alignment_parent = v
	build_words()

var buffer_left_margin : int setget buffer_left_margin_setter
func buffer_left_margin_setter(v):
	buffer_left_margin = v
	layout()
var buffer_right_margin : int setget buffer_right_margin_setter
func buffer_right_margin_setter(v):
	buffer_right_margin = v
	layout()
var buffer_left_padding : int setget buffer_left_padding_setter
func buffer_left_padding_setter(v):
	buffer_left_padding = v
	layout()
var buffer_right_padding : int setget buffer_right_padding_setter
func buffer_right_padding_setter(v):
	buffer_right_padding = v
	layout()
var buffer_visible_border : bool setget buffer_visible_border_setter
func buffer_visible_border_setter(v):
	buffer_visible_border = v
	update()

var adjust_line_height : int setget adjust_line_height_setter
func adjust_line_height_setter(v):
	adjust_line_height = v
	layout()
var adjust_ruby_distance : int setget adjust_ruby_distance_setter
func adjust_ruby_distance_setter(v):
	adjust_ruby_distance = v
	layout()
var adjust_no_ruby_space : int setget adjust_no_ruby_space_setter
func adjust_no_ruby_space_setter(v):
	adjust_no_ruby_space = v
	layout()
	
var text_input : String setget text_input_setter
func text_input_setter(value):
	text_input = value
	build_words()
var text_ruby_parent : String = "｜" setget text_ruby_parent_setter
func text_ruby_parent_setter(v):
	text_ruby_parent = v
	if set_regex():
		build_words()
var text_ruby_begin : String = "《" setget text_ruby_begin_setter
func text_ruby_begin_setter(v):
	text_ruby_begin = v
	if set_regex():
		build_words()
var text_ruby_end : String = "》" setget text_ruby_end_setter
func text_ruby_end_setter(v):
	text_ruby_end = v
	if set_regex():
		build_words()
	
enum HorizontalAlignment {LEFT,CENTER,RIGHT}
var display_horizontal_alignment : int setget horizontal_alignment_setter
func horizontal_alignment_setter(v):
	display_horizontal_alignment = v
	update()
enum VerticalAlignment {TOP,CENTER,BOTTOM}
var display_vertical_alignment : int setget display_vertical_alignment_setter
func display_vertical_alignment_setter(v):
	display_vertical_alignment = v
	update()
	
var display_rate : float = 100 setget display_rate_setter
func display_rate_setter(v):
	display_rate = v
	if not output_base_text.empty():
		update()
var display_rate_phonetic : bool setget display_rate_phonetic_setter
func display_rate_phonetic_setter(v):
	display_rate_phonetic = v
	layout()

var output_base_text : String setget output_base_text_setter
func output_base_text_setter(_v):
	pass
var output_phonetic_text : String setget output_phonetic_text_setter
func output_phonetic_text_setter(_v):
	pass

var clip_rect : bool setget clip_rect_setter
func clip_rect_setter(v):
	clip_rect = v
	update()
var auto_fit_height : bool setget auto_fit_height_setter
func auto_fit_height_setter(v):
	auto_fit_height = v
	layout()


func set_regex() -> bool:
	if not text_ruby_parent.empty() and not text_ruby_begin.empty() and not text_ruby_end.empty():
		return ruby_regex.compile(Ruby.RubyString.regex_escape(text_ruby_parent) +
				"(?<p>.+?)" + Ruby.RubyString.regex_escape(text_ruby_begin) +
				"(?<r>.+?)" + Ruby.RubyString.regex_escape(text_ruby_end)) == OK
	return false

var ruby_regex : RegEx = RegEx.new()
var line_break_word : Ruby.LineBreakWord = Ruby.LineBreakWord.new()
var unbreakable_words : Array # of UnbreakableWordData
var lines : Array # of RubyLabelLine
var layout_height : float


func _ready():
	layout()
	connect("tree_entered",self,"layout")
	connect("resized",self,"layout")


class RubyLabelChar:
	var x : float
	var y : float
	var width : float
	var character : int
	var next : int
	var start : float
	var end : float
	
	func _init(x_,y_,w,c,n,s,e):
		x = x_
		y = y_
		width = w
		character = c
		next = n
		start = s
		end = e

class RubyLabelLine:
	var base : Array # of RubyLabelChar
	var ruby : Array # of RubyLabelChar
	
	func _init(b,r):
		base = b
		ruby = r
	
	static func create(line_words : Array,line_words_x : PoolRealArray,font : Font,font_ruby : Font,
			text_pos : int,y:float,has_ruby:bool,ruby_distance : float,no_ruby_space : float) -> RubyLabelLine:
		var line_chars = []
		var line_ruby_chars = []
		var ruby_height : float = font_ruby.get_height() + ruby_distance
		
		var by = y + (ruby_height if has_ruby else float(no_ruby_space)) + font.get_ascent()
		for i in line_words.size():
			var word := line_words[i] as UnbreakableWordData
			var start_pos : PoolRealArray = []
			for j in word.base_text_data.size():
				start_pos.append(text_pos)
				var unit = word.base_text_data[j] as RubyUnitWordData
				var bx = line_words_x[i] + word.base_text_x[j]
				for k in unit.char_width.size():
					var c = RubyLabelChar.new(bx,by,unit.char_width[k],
							unit.code[k],unit.code[k+1],text_pos,text_pos + 1)
					bx += unit.char_width[k]
					text_pos += 1
					line_chars.append(c)
			start_pos.append(text_pos)
			for j in word.ruby_text_data.size():
				var unit = word.ruby_text_data[j] as RubyUnitWordData
				var bx = line_words_x[i] + word.ruby_text_x[j]
				var target = word.ruby_target[j]
				var d = start_pos[target+1] - start_pos[target]
				for k in unit.char_width.size():
					var s = start_pos[target] + d * k / unit.char_width.size()
					var e = start_pos[target] + d * (k+1) / unit.char_width.size()
					var c = RubyLabelChar.new(bx,y + font_ruby.get_ascent(),unit.char_width[k],
							unit.code[k],unit.code[k+1],s,e)
					bx += unit.char_width[k]
					line_ruby_chars.append(c)
		return RubyLabelLine.new(line_chars,line_ruby_chars)

	static func create_by_phonetic(line_words : Array,line_words_x : PoolRealArray,font : Font,font_ruby : Font,
			text_pos : int,y:float,has_ruby:bool,ruby_distance : float,no_ruby_space : float) -> RubyLabelLine:
		var line_chars = []
		var line_ruby_chars = []
		var ruby_height : float = font_ruby.get_height() + ruby_distance
		
		var by = y + (ruby_height if has_ruby else float(no_ruby_space)) + font.get_ascent()
		for i in line_words.size():
			var word := line_words[i] as UnbreakableWordData
			if not word.has_ruby():
				for j in word.base_text_data.size():
					var unit = word.base_text_data[j] as RubyUnitWordData
					var bx = line_words_x[i] + word.base_text_x[j]
					for k in unit.char_width.size():
						var c = RubyLabelChar.new(bx,by,unit.char_width[k],
								unit.code[k],unit.code[k+1],text_pos,text_pos + 1)
						bx += unit.char_width[k]
						text_pos += 1
						line_chars.append(c)
				continue
			var start_pos : PoolRealArray = []
			for j in word.ruby_text_data.size():
				start_pos.append(text_pos)
				var unit = word.ruby_text_data[j] as RubyUnitWordData
				var bx = line_words_x[i] + word.ruby_text_x[j]
				for k in unit.char_width.size():
					var c = RubyLabelChar.new(bx,y + font_ruby.get_ascent(),unit.char_width[k],
							unit.code[k],unit.code[k+1],text_pos,text_pos + 1)
					bx += unit.char_width[k]
					text_pos += 1
					line_ruby_chars.append(c)
			start_pos.append(text_pos)
			for j in word.base_text_data.size():
				var unit := word.base_text_data[j] as RubyUnitWordData
				var bx = line_words_x[i] + word.base_text_x[j]
				var target : int
				for k in word.ruby_target.size():
					if word.ruby_target[k] == j:
						target = k
						break
				var d = start_pos[target+1] - start_pos[target]
				for k in unit.char_width.size():
					var s = start_pos[word.ruby_target[target]] + d * k / unit.char_width.size()
					var e = start_pos[word.ruby_target[target]] + d * (k+1) / unit.char_width.size()
					var c = RubyLabelChar.new(bx,by,unit.char_width[k],
							unit.code[k],unit.code[k+1],s,e)
					bx += unit.char_width[k]
					line_chars.append(c)
		return RubyLabelLine.new(line_chars,line_ruby_chars)

class RubyUnitWordData:
	var code : PoolIntArray = []
	var width : float = 0
	var char_width : PoolRealArray = []

	func _init(word : String,font : Font,next_code : int):
		code.resize(word.length() + 1)
		for i in word.length():
			code[i] = word.ord_at(i)
		code[word.length()] = next_code
		char_width.resize(word.length())
		for i in word.length():
			char_width[i] = font.get_char_size(code[i],code[i+1]).x
			width += font.get_char_size(code[i],code[i+1]).x

class UnbreakableWordData:
	var base_text_data : Array = [] # of RubyUnitWordData
	var base_text_x : PoolRealArray = []
	var ruby_text_data : Array = [] # of RubyUnitWordData
	var ruby_text_x : PoolRealArray = []
	var ruby_target : PoolIntArray = [] # of target base_text index
	var width : float
	
	func get_width() -> float:
		return width
	func get_ruby_width() -> float:
		return 0.0 if ruby_text_x.empty() else (ruby_text_x[ruby_text_x.size()-1] - ruby_text_x[0] + ruby_text_data.back().width)
	func get_left_ruby_buffer() -> float:
		return get_width() if ruby_text_x.empty() else ruby_text_x[0]
	func get_right_ruby_buffer() -> float:
		return get_width() - (0 if ruby_text_x.empty() else ruby_text_x[ruby_text_x.size()-1] + ruby_text_data.back().width)
	func has_ruby() -> bool:
		return not ruby_text_data.empty()

	func _init(word : Ruby.UnbreakableWord,font : Font,font_ruby : Font,next_code : int,
			ruby_alignment_ruby : int,ruby_alignment_parent : int):
		if not word.has_ruby():
			var b_data := RubyUnitWordData.new(word.word,font,next_code)
			base_text_data = [b_data]
			base_text_x = [0]
			width = b_data.width
			return
		
		var x : float = 0
		var next : int = 0
		var ruby_buffer : float = +INF
		var index = 0
		for u_ in word.ruby_units:
			var u = u_ as Ruby.RubyUnit
			next += u.base_text.length()
			var n_code =  word.word.ord_at(next) if next < word.word.length() else next_code

			if u.has_ruby():
				var b_data := RubyUnitWordData.new(u.base_text,font,n_code)
				var r_data := RubyUnitWordData.new(u.ruby_text,font_ruby,-1)

				if ruby_alignment_ruby != RubyAlignment.CENTER and\
						b_data.width > r_data.width and r_data.char_width.size() > 1:
					var ruby_offset : float
					var space : float
					match ruby_alignment_ruby:
						RubyAlignment.SPACE121:
							ruby_offset = (b_data.width - r_data.width) / (r_data.char_width.size() * 2)
							space = ruby_offset * 2
						RubyAlignment.SPACE010:
							ruby_offset = 0
							space = (b_data.width - r_data.width) / (r_data.char_width.size() -1)
						
					r_data.width = b_data.width - ruby_offset * 2
					var new_width : PoolRealArray = []
					for w in r_data.char_width:
						new_width.append(w + space)
					r_data.char_width = new_width
					if ruby_buffer + ruby_offset < 0:
						x += -(ruby_buffer + ruby_offset)
					base_text_data.append(b_data)
					base_text_x.append(x)
					ruby_text_data.append(r_data)
					ruby_text_x.append(x + ruby_offset)
					x += b_data.width
					ruby_buffer = ruby_offset
					ruby_target.append(index)
				elif ruby_alignment_parent != ParentAlignment.NOTHING and b_data.width < r_data.width:
					var base_offset : float
					var space : float
					var sub : float = r_data.width - b_data.width
					var count = b_data.char_width.size()
					if ruby_alignment_parent != ParentAlignment.CENTER and count > 1:
						match ruby_alignment_parent:
							ParentAlignment.SPACE121:
								base_offset = sub / (count * 2)
								space = base_offset * 2
							ParentAlignment.SPACE010:
								base_offset = 0
								space = sub / (count - 1)
					else:
						base_offset = sub/2
						space = 0
				
					var new_width : PoolRealArray = []
					for w in b_data.char_width:
						new_width.append(w + space)
					b_data.char_width = new_width
					base_text_data.append(b_data)
					base_text_x.append(x + base_offset)
					ruby_text_data.append(r_data)
					ruby_text_x.append(x)
					x += r_data.width
					ruby_buffer = 0
					ruby_target.append(index)
				else:
					var sub := (b_data.width - r_data.width)/2
					if ruby_buffer + sub < 0:
						x += -(ruby_buffer + sub)
					base_text_data.append(b_data)
					base_text_x.append(x)
					ruby_text_data.append(r_data)
					ruby_text_x.append(x + sub)
					x += b_data.width
					ruby_buffer = sub
					ruby_target.append(index)
			else:
				var b_data := RubyUnitWordData.new(u.base_text,font,n_code)
				base_text_data.append(b_data)
				base_text_x.append(x)
				x += b_data.width
				ruby_buffer += b_data.width
			index += 1
		width = x

func build_words():
	if text_input.empty() or not ruby_regex.is_valid():
		return
	var font := font_font if font_font else get_theme_default_font()
	var ruby_font := font_ruby_font if font_ruby_font else get_theme_default_font()
	if not font or not ruby_font:
		return

	var ruby_text = Ruby.RubyString.create_by_regex(text_input,line_break_word,ruby_regex)
	unbreakable_words.clear()
	output_base_text = ruby_text.get_base_text()
	output_phonetic_text = ruby_text.get_phonetic_text()
	var text_pos : int = 0
	for w_ in ruby_text.words:
		var w  = w_ as Ruby.UnbreakableWord
		text_pos += w.word.length()
		var next_code = output_base_text.ord_at(text_pos) if text_pos < output_base_text.length() else 0
		unbreakable_words.append(UnbreakableWordData.new(w,font,ruby_font,next_code,
				ruby_alignment_ruby,ruby_alignment_parent))
	layout()


func layout():
	if not get_parent():
		return
	lines = []
	if unbreakable_words.empty():
		return
	var font := font_font if font_font else get_theme_default_font()
	var ruby_font := font_ruby_font if font_ruby_font else get_theme_default_font()
	if not font or not ruby_font:
		return

	var x : float = buffer_left_padding
	var y : float = 0
	var ruby_height : float = ruby_font.get_height() + adjust_ruby_distance
	var line_height : float = font.get_height() + adjust_line_height
	var ruby_buffer : float = buffer_left_margin + buffer_left_padding
	var text_pos = 0
	var line_words = [] # of UnbreakableWordData
	var line_words_x : PoolRealArray= []
	var line_has_ruby : bool = false
	for w_ in unbreakable_words:
		var w = w_ as UnbreakableWordData
		if line_words.empty():
			if w.base_text_data[0].code[0] == ord("\n"):
				y += line_height + adjust_no_ruby_space
				text_pos += 1
				continue
			
			line_words.append(w)
			x = max(-w.get_left_ruby_buffer() - buffer_left_margin - buffer_left_padding,0) + buffer_left_padding
			line_words_x.append(x)
			x += w.get_width()
			if w.has_ruby():
				ruby_buffer = w.get_right_ruby_buffer()
				line_has_ruby = true
			else:
				ruby_buffer += w.get_width()
			continue

		var base_x = x + w.get_width() - min(ruby_buffer + w.get_left_ruby_buffer(),0)
		var ruby_x = x - min(ruby_buffer + w.get_left_ruby_buffer(),0) + w.get_width() - min(w.get_right_ruby_buffer(),0)
		if w.base_text_data[0].code[0] == ord("\n") or\
				base_x > rect_size.x - buffer_right_padding or\
				(w.has_ruby() and ruby_x > rect_size.x + buffer_right_margin):
			if display_rate_phonetic:
				lines.append(RubyLabelLine.create_by_phonetic(line_words,line_words_x,
						font,ruby_font,text_pos,y,line_has_ruby,adjust_ruby_distance,adjust_no_ruby_space))
				for lw_ in line_words:
					var lw = lw_ as UnbreakableWordData
					lw.ruby_target.size()
					for btd in lw.base_text_data:
						text_pos += btd.char_width.size()
					for i in lw.ruby_text_data.size():
						text_pos += lw.ruby_text_data[i].char_width.size() - lw.base_text_data[lw.ruby_target[i]].char_width.size()
			else:
				lines.append(RubyLabelLine.create(line_words,line_words_x,
						font,ruby_font,text_pos,y,line_has_ruby,adjust_ruby_distance,adjust_no_ruby_space))
				for lw in line_words:
					for btd in lw.base_text_data:
						text_pos += btd.char_width.size()
			x = buffer_left_padding
			y += line_height + (ruby_height if line_has_ruby else float(adjust_no_ruby_space))
			ruby_buffer = buffer_left_margin + buffer_left_padding
			line_words.clear()
			line_words_x.resize(0)
			line_has_ruby = false

		if w.base_text_data[0].code[0] == ord("\n"):
			text_pos += 1
			continue

		line_words.append(w)
		if w.has_ruby():
			x -= min(ruby_buffer + w.get_left_ruby_buffer(),0)
			line_has_ruby = true
			ruby_buffer = w.get_right_ruby_buffer()
		else:
			ruby_buffer += w.get_width()
		line_words_x.append(x)
		x += w.get_width()
	
	if not line_words.empty():
		var line
		if display_rate_phonetic:
			line = RubyLabelLine.create_by_phonetic(line_words,line_words_x,font,ruby_font,text_pos,y,
					line_has_ruby,adjust_ruby_distance,adjust_no_ruby_space)
		else:
			line = RubyLabelLine.create(line_words,line_words_x,font,ruby_font,text_pos,y,
					line_has_ruby,adjust_ruby_distance,adjust_no_ruby_space)
		lines.append(line)
		y += line_height + (float(adjust_no_ruby_space) if line.ruby.empty() else ruby_height)

	layout_height = (y - adjust_line_height) if adjust_line_height < 0 else y

	if auto_fit_height:
		rect_min_size.y = layout_height
		rect_size.y = layout_height
	update()

func _draw():
	var font := font_font if font_font else get_theme_default_font()
	var ruby_font := font_ruby_font if font_ruby_font else get_theme_default_font()
	if not font or not ruby_font:
		return

	var y_offset : float = 0
	match display_vertical_alignment:
		VerticalAlignment.TOP:
			pass
		VerticalAlignment.CENTER:
			y_offset = (rect_size.y - layout_height) / 2
		VerticalAlignment.BOTTOM:
			y_offset = (rect_size.y - layout_height)
	
	if clip_rect:
		VisualServer.canvas_item_set_custom_rect(get_canvas_item(),true,
				Rect2(-buffer_left_margin-1,0,buffer_left_margin+1 + rect_size.x + buffer_right_margin+1,rect_size.y))
		VisualServer.canvas_item_set_clip(get_canvas_item(), true)
	else:
		VisualServer.canvas_item_set_clip(get_canvas_item(), false)
	if buffer_visible_border:
		draw_line(Vector2(-buffer_left_margin,0),Vector2(-buffer_left_margin,rect_size.y),Color.white)
		draw_line(Vector2(buffer_left_padding,0),Vector2(buffer_left_padding,rect_size.y),Color.white)
		draw_line(Vector2(rect_size.x - buffer_right_padding,0),Vector2(rect_size.x - buffer_right_padding,rect_size.y),Color.white)
		draw_line(Vector2(rect_size.x + buffer_right_margin,0),Vector2(rect_size.x + buffer_right_margin,rect_size.y),Color.white)

	var count = (output_phonetic_text.length() if display_rate_phonetic else output_base_text.length()) * display_rate/100
	if display_horizontal_alignment == HorizontalAlignment.LEFT:
		for l in lines:
			for c_ in l.base:
				var c := c_ as RubyLabelChar
				if count >= c.end:
					font.draw_char(get_canvas_item(),Vector2(c.x,c.y + y_offset),c.character,c.next,font_outline_color,true)
				elif count > c.start:
					var fadecolor := font_outline_color
					fadecolor.a = (count - c.start) / (c.end - c.start)
					font.draw_char(get_canvas_item(),Vector2(c.x,c.y + y_offset),c.character,c.next,fadecolor,true)
		for l in lines:
			for c_ in l.ruby:
				var c := c_ as RubyLabelChar
				if count >= c.end:
					ruby_font.draw_char(get_canvas_item(),Vector2(c.x,c.y + y_offset),c.character,c.next,font_outline_color,true)
				elif count > c.start:
					var fadecolor := font_outline_color
					fadecolor.a = (count - c.start) / (c.end - c.start)
					ruby_font.draw_char(get_canvas_item(),Vector2(c.x,c.y + y_offset),c.character,c.next,fadecolor,true)
		for l in lines:
			for c_ in l.base:
				var c := c_ as RubyLabelChar
				if count >= c.end:
					font.draw_char(get_canvas_item(),Vector2(c.x,c.y + y_offset),c.character,c.next,font_color)
				elif count > c.start:
					var fadecolor := font_color
					fadecolor.a = (count - c.start) / (c.end - c.start)
					font.draw_char(get_canvas_item(),Vector2(c.x,c.y + y_offset),c.character,c.next,fadecolor)
		for l in lines:
			for c_ in l.ruby:
				var c := c_ as RubyLabelChar
				if count >= c.end:
					ruby_font.draw_char(get_canvas_item(),Vector2(c.x,c.y + y_offset),c.character,c.next,font_color)
				elif count > c.start:
					var fadecolor := font_color
					fadecolor.a = (count - c.start) / (c.end - c.start)
					ruby_font.draw_char(get_canvas_item(),Vector2(c.x,c.y + y_offset),c.character,c.next,fadecolor)
		return

	var slides := PoolRealArray([])
	slides.resize(lines.size())
	if display_horizontal_alignment == HorizontalAlignment.RIGHT:
		for i in lines.size():
			var l := lines[i] as RubyLabelLine
			if not l.base.empty():
				var left = l.base.front().x
				var right = l.base.back().x + l.base.back().width
				if not l.ruby.empty():
					left = min(left,l.ruby.front().x)
					right = max(right,l.ruby.back().x + l.ruby.back().width)
				var width = right - left
				slides[i]  = (rect_size.x - buffer_right_padding) - (buffer_left_padding + width)
	elif display_horizontal_alignment == HorizontalAlignment.CENTER:
		for i in lines.size():
			var l := lines[i] as RubyLabelLine
			if not l.base.empty():
				var left = l.base.front().x
				var right = l.base.back().x + l.base.back().width
				if not l.ruby.empty():
					left = min(left,l.ruby.front().x)
					right = max(right,l.ruby.back().x + l.ruby.back().width)
				var width = right - left
				var slide = (rect_size.x + buffer_left_padding - buffer_right_padding - width) / 2 - buffer_left_padding
				slides[i] = slide
	else:
		return

	for i in lines.size():
		var l := lines[i] as RubyLabelLine
		for c_ in l.base:
			var c := c_ as RubyLabelChar
			var pos = Vector2(c.x + slides[i],c.y + y_offset)
			if count >= c.end:
				font.draw_char(get_canvas_item(),pos,c.character,c.next,font_outline_color,true)
			elif count > c.start:
				var fadecolor := font_outline_color
				fadecolor.a = (count - c.start) / (c.end - c.start)
				font.draw_char(get_canvas_item(),pos,c.character,c.next,fadecolor,true)
	for i in lines.size():
		var l := lines[i] as RubyLabelLine
		for c_ in l.ruby:
			var c := c_ as RubyLabelChar
			var pos = Vector2(c.x + slides[i],c.y + y_offset)
			if count >= c.end:
				ruby_font.draw_char(get_canvas_item(),pos,c.character,c.next,font_outline_color,true)
			elif count > c.start:
				var fadecolor := font_outline_color
				fadecolor.a = (count - c.start) / (c.end - c.start)
				ruby_font.draw_char(get_canvas_item(),pos,c.character,c.next,fadecolor,true)
	for i in lines.size():
		var l := lines[i] as RubyLabelLine
		for c_ in l.base:
			var c := c_ as RubyLabelChar
			var pos = Vector2(c.x + slides[i],c.y + y_offset)
			if count >= c.end:
				font.draw_char(get_canvas_item(),pos,c.character,c.next,font_color)
			elif count > c.start:
				var fadecolor := font_color
				fadecolor.a = (count - c.start) / (c.end - c.start)
				font.draw_char(get_canvas_item(),pos,c.character,c.next,fadecolor)
	for i in lines.size():
		var l := lines[i] as RubyLabelLine
		for c_ in l.ruby:
			var c := c_ as RubyLabelChar
			var pos = Vector2(c.x + slides[i],c.y + y_offset)
			if count >= c.end:
				ruby_font.draw_char(get_canvas_item(),pos,c.character,c.next,font_color)
			elif count > c.start:
				var fadecolor := font_color
				fadecolor.a = (count - c.start) / (c.end - c.start)
				ruby_font.draw_char(get_canvas_item(),pos,c.character,c.next,fadecolor)
			

