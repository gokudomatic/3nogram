extends VSlider

func _ready():
	pass



func _on_Camera_center_zoom_change(value):
	self.value=(2-value)*100

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index==BUTTON_LEFT:
		game_data.is_interacting_gui=event.pressed

func _on_camera_center_zoom_change(value):
	self.value=(2-value)*100
