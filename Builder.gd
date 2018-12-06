extends Spatial

func _ready():
	game_data.touch_mode=game_data.TOUCH_NORMAL
	game_data.build_color=Color(1,1,1,1)
	if game_data.current_puzzle!=null:
		for d in game_data.current_puzzle.data:
			$manager.add_cell(d[0],d[1])
			$manager.recenter()


func _on_BuildBtn_toggled(button_pressed):
	if button_pressed:
		game_data.touch_mode=game_data.TOUCH_BUILD
		$CanvasLayer/Container/BreakBtn.pressed=false
		$CanvasLayer/Container/PaintBtn.pressed=false
	else:
		game_data.touch_mode=game_data.TOUCH_NORMAL


func _on_PaintBtn_toggled(button_pressed):
	if button_pressed:
		game_data.touch_mode=game_data.TOUCH_PAINT
		$CanvasLayer/Container/BreakBtn.pressed=false
		$CanvasLayer/Container/BuildBtn.pressed=false
	else:
		game_data.touch_mode=game_data.TOUCH_NORMAL


func _on_BreakBtn_toggled(button_pressed):
	if button_pressed:
		game_data.touch_mode=game_data.TOUCH_DESTROY
		$CanvasLayer/Container/PaintBtn.pressed=false
		$CanvasLayer/Container/BuildBtn.pressed=false
	else:
		game_data.touch_mode=game_data.TOUCH_NORMAL

func _on_ColorPicker_color_changed(color):
	game_data.build_color=color

func save_puzzle():
	if game_data.current_puzzle!=null:
		game_data.current_puzzle.data=$manager.get_data()
		game_data.current_puzzle.dimensions=$manager.last_dimensions+Vector3(1,1,1)
		game_data.save_to_file()

func _on_MenuBtn_pressed():
	$CanvasLayer/MenuDialog.popup_centered()

func _on_PropertiesBtn_pressed():
	save_puzzle()
	get_tree().change_scene("res://PuzzleProperties.tscn")

func _on_HintsBtn_pressed():
	save_puzzle()
	get_tree().change_scene("res://HintEditor.tscn")

func _on_CloseBtn_pressed():
	$CanvasLayer/MenuDialog.hide()
