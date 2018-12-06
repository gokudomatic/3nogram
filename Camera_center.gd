extends Spatial

var pressed=false
export(float) var sensitivity=0.005;
var zoom_level=1 setget set_zoom_level

signal zoom_change(value)
signal position_changed(camera)

func _ready():
	emit_signal("position_changed",$Camera_pitch/Camera)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index==BUTTON_LEFT and game_data.touch_mode==game_data.TOUCH_NORMAL:
			pressed=event.pressed
		elif event.button_index==BUTTON_RIGHT:
			pressed=event.pressed
		elif event.button_index==BUTTON_WHEEL_UP:
			# zoom in
			set_zoom_level(zoom_level-0.1)
		elif event.button_index==BUTTON_WHEEL_DOWN:
			# zoom out
			set_zoom_level(zoom_level+0.1)
	
	if event is InputEventMouseMotion and pressed and !game_data.is_interacting_gui:
		var old_pitch_transform=$Camera_pitch.transform
		$Camera_pitch.rotate_x(event.relative.y*-sensitivity)
		if $Camera_pitch.transform.basis.y.y<0:
			$Camera_pitch.transform=old_pitch_transform
		rotate_y(event.relative.x*-sensitivity)
		
		emit_signal("position_changed",$Camera_pitch/Camera)

func set_zoom_level(value,dont_emit=false):
	zoom_level=max(0,min(2,value))
	$Camera_pitch/Camera.translation.z=10+15*zoom_level
	if not dont_emit:
		emit_signal("zoom_change",zoom_level)

func _on_ZoomSlider_value_changed(value):
	set_zoom_level(2-value/100,true)
