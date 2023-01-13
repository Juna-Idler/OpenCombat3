extends Reference

class_name Ruby


class RubyUnit:
	var base_text : String
	var ruby_text : String
	
	func _init(b:String,r:String):
		base_text = b;
		ruby_text = r;
		
	func has_ruby() -> bool:
		return not ruby_text.empty()


class UnbreakableWord:
	var ruby_units : Array # of RubyUnit
	var word : String = ""
	
	func _init(ru : Array):
		for u in ru:
			word += u.base_text
		ruby_units = [] if ru.size() == 1 and not ru[0].has_ruby() else ru
		
	func has_ruby() -> bool:
		return not ruby_units.empty()
	
	func get_phonetic() -> String:
		if ruby_units.empty():
			return word
		var r : String = ""
		for u in ruby_units:
			r += u.ruby_text if u.has_ruby() else u.base_text
		return r


class RubyString:
	var words : Array # of UnbreakbleWord

	func _init(w : Array):
		words = w
		
	func get_base_text() -> String:
		var r : String = ""
		for w in words:
			r += w.word
		return r

	func get_phonetic_text() -> String:
		var r : String = ""
		for w in words:
			r += w.get_phonetic()
		return r

	func has_ruby() -> bool:
		for w in words:
			if w.has_ruby():
				return true
		return false


	static func regex_escape(text : String) -> String:
		for c in ["\\","*","+","?","|","{","}","[","]","(",")","^","$",".","#"]:
			text = text.replace(c,"\\"+c)
		return text


	static func create(text : String,line_break : ILineBreakWord,
			parent:String,begin:String,end:String) -> RubyString:
		if parent.empty() or begin.empty() or end.empty():
			return create_by_regex(text,line_break,null)
		var pattern = regex_escape(parent) + "(?<p>.+?)" + regex_escape(begin) + "(?<r>.+?)" + regex_escape(end);
		var regex = RegEx.new()
		regex.compile(pattern)
		return create_by_regex(text,line_break,regex)
		
	static func create_by_regex(text : String,line_break : ILineBreakWord,regex : RegEx) -> RubyString:
		if not regex:
			var result = []
			var lb_words := line_break.separate_word(text)
			for w in lb_words:
				result.append(UnbreakableWord.new([RubyUnit.new(w,"")]))
			return RubyString.new(result)
		var result = []
		var stock_units = []
		var target := text
		while true:
			var m = regex.search(target)
			if m:
				if m.get_start() > 0:
					var lb_words := line_break.separate_word(target.substr(0,m.get_start()))
					if not stock_units.empty():
						var prev = stock_units.back().base_text
						if not line_break.is_link(prev[prev.length()-1],lb_words[0][0]):
							result.append(UnbreakableWord.new(stock_units))
							stock_units = []
					stock_units.append(RubyUnit.new(lb_words[0],""))
					if lb_words.size() >= 2:
						result.append(UnbreakableWord.new(stock_units))
						stock_units = []
						for i in range(1,lb_words.size()-1):
							result.append(UnbreakableWord.new([RubyUnit.new(lb_words[i],"")]))
						stock_units.append(RubyUnit.new(lb_words[lb_words.size()-1],""))
				var ruby = RubyUnit.new(m.get_string("p"),m.get_string("r"))
				if not stock_units.empty():
					var prev = stock_units.back().base_text
					if not line_break.is_link(prev[prev.length()-1],ruby.base_text[0]):
						result.append(UnbreakableWord.new(stock_units))
						stock_units = []
				stock_units.append(ruby)
				if m.get_end() == target.length():
					break
				target = target.substr(m.get_end())
			else:
				var lb_words := line_break.separate_word(target)
				if not stock_units.empty():
					var prev = stock_units.back().base_text
					if not line_break.is_link(prev[prev.length()-1],lb_words[0][0]):
						result.append(UnbreakableWord.new(stock_units))
						stock_units = []
				stock_units.append(RubyUnit.new(lb_words[0],""))
				result.append(UnbreakableWord.new(stock_units))
				stock_units = []
				for i in range(1,lb_words.size()):
					result.append(UnbreakableWord.new([RubyUnit.new(lb_words[i],"")]))
				break
		if not stock_units.empty():
			result.append(UnbreakableWord.new(stock_units))
		
		return RubyString.new(result)
		


class ILineBreakWord:
	func separate_word(text : String) -> PoolStringArray:
		return PoolStringArray([text])
	func is_link(c1 : String,c2 : String) -> bool:
		return true

class NoBreakLineBreakWord extends ILineBreakWord:
	func separate_word(text : String) -> PoolStringArray:
		return PoolStringArray([text])
	func is_link(c1 : String,c2 : String) -> bool:
		return true

class LineBreakWord extends ILineBreakWord:
	func separate_word(text : String) -> PoolStringArray:
		if text.empty():
			return PoolStringArray()

		var words : PoolStringArray = []
		var c1 := text[0]
		var link := c1
		for i in range(1,text.length()):
			var c2 = text[i]
			if is_link(c1,c2):
				link += c2
			else:
				words.append(link)
				link = c2
			c1 = c2
		words.append(link)
		return words

	var force_break := " \t\r\n　@*|/";
	var force_link1 := "([{\"'<‘“（〔［｛〈《「『【";
	var force_link2 := ",.;:)]}\"'>、。，．’”）〕］｝〉》」』】";
	var not_begin := "・：；？！ヽヾゝゞ〃々ー―～…‥っゃゅょッャュョぁぃぅぇぉァィゥェォ";
	var next_break1 := ")]};>!%&?";
	var num_link_next_break1 := ".,-:$\\";
	var prev_break2 := "([{<";

	func is_link(c1 : String,c2 : String) -> bool:
		if c1 in force_break or c2 in force_break:
			return false

		if c1 in force_link1 or c2 in force_link2:
			return true

		if ord(c1) <= 0x7F:
			if c1 in next_break1:
				return false
			if c2 in prev_break2:
				return false
			if c1 in num_link_next_break1:
				if ord("0") <= ord(c2) and ord(c2) <= ord("9"):
					return true
				else:
					return false

			if ord(c2) <= 0x7F:
				return true
			return false

		if c2 in not_begin:
			return true

		return false

