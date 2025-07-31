class_name IdleNumber

var _num_places: Array[int] = [0]

func _init(starting_value: String = "0") -> void:
	_num_places = num_to_array(starting_value)

func display_value(significant_figures: int = 3, append_suffix: bool = true) -> String:
	var highest_place: int = _num_places.back()
	var amount_suffix: String = Utils.NUMBER_SUFFIXES.find_key(_num_places.size() - 2) if _num_places.size() > 1 else ""
	
	var result: String = str(highest_place)
	
	var _result_length: int = result.length()
	if _result_length < significant_figures and _num_places.size() > 1:
		var substr_length: int = significant_figures - _result_length
		var second_highest_place: String = str(_num_places[-2]).pad_zeros(3) # e.g., 123 -> 123, 12 -> 012, 1 -> 001
		second_highest_place = second_highest_place.substr(0, substr_length)
		result = "%s.%s" % [result, second_highest_place]
	
	return "%s%s" % [result, amount_suffix] if append_suffix else result

static func num_to_array(large_num: String) -> Array[int]:
	var arr: Array[int] = []
	
	var curr_length: int = large_num.length()
	while curr_length > 0:
		var substr_length: int = min(curr_length, 3)
		
		var curr_place: int = int(large_num.substr(curr_length - substr_length, substr_length))
		arr.append(curr_place)
		
		curr_length -= substr_length
	
	return arr

func array_to_num(places: Array[int] = _num_places) -> String:
	var result: String = ""
	
	var last_index: int = places.size() - 1
	for i in range(last_index, -1, -1):
		result += str(places[i]).pad_zeros(3 if i < last_index else 2)
		
	return result

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
	var appended: bool = false
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
		
		if appended or diff > 0:
			result.append(diff)
			appended = true
	
	while result.back() == 0:
		result.pop_back()
	
	if result.size() == 0:
		result = [0]
		
	_num_places = result
	
func multiply(value: float) -> void:
	var result: Array[int] = []
	
	var temp_places: Array[int] = _num_places.duplicate()
	var _temp_size: int = temp_places.size()
	
	var carry: int = 0
	while _temp_size > 0 or carry > 0:
		var curr_place: int = 0
		
		if _temp_size > 0:
			curr_place += temp_places.pop_front()
			_temp_size -= 1
			curr_place *= value
			
		curr_place += carry
		
		# limit result to 1s, 10s and 100s places
		# e.g., 9318 -> 318, carry: 9
		carry = curr_place / 1000
		curr_place %= 1000
		
		result.append(curr_place)
	
	_num_places = result

func compare(money_to_check: IdleNumber) -> bool:
	var money_check_size: int = money_to_check._num_places.size()
	var curr_money_size: int = _num_places.size()
	
	if money_check_size > curr_money_size:
		return false
	
	if curr_money_size > money_check_size:
		return true
	
	for i in range(money_check_size - 1, -1, -1):
		if money_to_check._num_places[i] > _num_places[i]:
			return false
		elif _num_places[i] > money_to_check._num_places[i]:
			return true
	
	return true
