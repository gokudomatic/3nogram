extends Node
#
#class Cat:
#	var name = "Felix"
#
#
#class Example:
#	var x = 42
#	var y = PI
#	var name = "yolo"
#	var cat = Cat.new()


func _ready():
	var data = {}
	data["hello"] = "world"
	data["x"] = 42
	data["y"] = PI
	data["pos"] = Vector2(100,50)
	data["pos3d"] = Vector3()
	var jdata = encode(data)
	print(jdata)
	data = decode(jdata)
	print(data)


# Parses special datatypes from string if they respect the format "TypeName(arg,arg,arg)"
static func decode(v):
	var type = typeof(v)
	
	if type == TYPE_STRING:
		if v.length() < 3 or not v.ends_with(")"):
			return v
		
		var bi = v.find("(")
		if bi < 1:
			return v
		
		var spi = v.find(" ")
		if spi != -1 and spi < bi:
			return v
		
		var type_name = v.substr(0, bi)
		var args = v.substr(bi + 1, v.length() - 1)
		
		var ft = args.split_floats(",")
		
		if ft.size() == 2:
			return Vector2(ft[0], ft[1])
			
		elif ft.size() == 3:
			return Vector3(ft[0], ft[1], ft[2])
			
		elif ft.size() == 4:
			if type_name == "Color":
				return Color(ft[0], ft[1], ft[2], ft[3])
				
			elif type_name == "Quat":
				return Quat(ft[0], ft[1], ft[2], ft[3])
				
			elif type_name == "Rect2":
				return Rect2(ft[0], ft[1], ft[2], ft[3])
				
		elif ft.size() == 6:
			if type_name == "AABB":
				return Rect2(Vector3(ft[0], ft[1], ft[2]), Vector3(ft[3], ft[4], ft[5]))
	
	elif type == TYPE_DICTIONARY:
		var decoded_dictionary = {}
		for k in v:
			var dk = decode(k)
			var dv = decode(v[k])
			decoded_dictionary[k] = dv
		return decoded_dictionary
	
	elif type == TYPE_ARRAY:
		var decoded_array = []
		decoded_array.resize(v.size())
		var i = 0
		while i < v.size():
			decoded_array[i] = decode(v[i])
			i += 1
		return decoded_array
	
	return v


static func encode(v):
	var type = typeof(v)
	
	if type == TYPE_VECTOR2:
		return "Vector2({0}, {1})".format([v.x, v.y])
		
	elif type == TYPE_VECTOR3:
		return "Vector3({0}, {1}, {2})".format([v.x, v.y, v.z])
		
	elif type == TYPE_COLOR:
		return "Color({0}, {1}, {2}, {3})".format([v.r, v.g, v.b, v.a])
		
	elif type == TYPE_QUAT:
		return "Quat({0}, {1}, {2}, {3})".format([v.x, v.y, v.z, v.w])
	
	elif type == TYPE_RECT2:
		var p = v.pos
		var s = v.size
		return "Rect2({0}, {1}, {2}, {3})".format([p.x, p.y, s.x, s.y])
	
	elif type == TYPE_AABB:
		var p = v.pos
		var s = v.size
		return "AABB({0}, {1}, {2}, {3}, {4}, {5})".format([p.x, p.y, p.z, s.x, s.y, s.z])
	
	elif type == TYPE_DICTIONARY:
		var encoded_dict = {}
		for k in v:
			var ek = encode(k)
			var ev = encode(v[k])
			encoded_dict[ek] = ev
		return encoded_dict
			
	elif type == TYPE_ARRAY:
		var encoded_array = []
		encoded_array.resize(v.size())
		var i = 0
		while i < v.size():
			encoded_array[i] = encode(v[i])
			i += 1
		return encoded_array
	
	return v
