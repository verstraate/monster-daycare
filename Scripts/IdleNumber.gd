class_name IdleNumber

var _num_places: Array[int]

func _init() -> void:
	_num_places = [0]

func display_value(significant_figures: int = 3) -> String:
	var highest_place: int = _num_places.back()
	var amount_suffix: String = Enums.BigNumberAmounts.find_key(_num_places.size() - 2) if _num_places.size() > 1 else ""
	
	var result: String = str(highest_place)
	
	var _result_length: int = result.length()
	if _result_length < significant_figures and _num_places.size() > 1:
		var substr_length: int = significant_figures - _result_length
		var second_highest_place: String = str(_num_places[-2]).pad_zeros(3) # e.g., 123 -> 123, 12 -> 012, 1 -> 001
		second_highest_place = second_highest_place.substr(0, substr_length)
		result = "%s.%s" % [result, second_highest_place]
	
	return "%s%s" % [result, amount_suffix]

static func num_to_array(large_num: String) -> Array[int]:
	var arr: Array[int] = []
	
	var curr_length: int = large_num.length()
	while curr_length > 0:
		var substr_length: int = min(curr_length, 3)
		
		var curr_place: int = int(large_num.substr(curr_length - substr_length, substr_length))
		arr.append(curr_place)
		
		curr_length -= substr_length
	
	return arr

func add(value: String) -> void:
	var result: Array[int] = []
	
	var temp_places: Array[int] = _num_places.duplicate()
	var _temp_size: int = temp_places.size()
	
	var value_places: Array[int] = num_to_array(value)
	var _value_size: int = value_places.size()
	
	var carry: int = 0
	while _temp_size > 0 or _value_size > 0 or carry > 0:
		var curr_place: int = 0
		
		if _temp_size > 0:
			curr_place += temp_places.pop_front()
			_temp_size -= 1
		if _value_size > 0:
			curr_place += value_places.pop_front()
			_value_size -= 1
			
		curr_place += carry
		
		# limit result to 1s, 10s and 100s places
		# e.g., 9318 -> 318, carry: 9
		carry = curr_place / 1000
		curr_place %= 1000
		
		result.append(curr_place)
	
	_num_places = result

func subtract(value: String) -> void:
	var result: Array[int] = []
	
	var temp_places: Array[int] = _num_places.duplicate()
	var _temp_size: int = temp_places.size()
	
	var value_places: Array[int] = num_to_array(value)
	var _value_size: int = value_places.size()
	
	var borrow: int = 0
	while _temp_size > 0 or _value_size > 0:
		var diff: int = 0
		
		if _temp_size > 0:
			diff += temp_places.pop_front()
			_temp_size -= 1
		if _value_size > 0:
			diff -= value_places.pop_front()
			_value_size -= 1
			
		diff -= borrow
		
		if diff < 0:
			diff += 1000
			borrow = 1
		else:
			borrow = 0
		
		result.append(diff)
	
	_num_places = result
