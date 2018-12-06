extends Spatial

func _ready():
	if game_data.current_puzzle!=null:
		start_puzzle(game_data.current_puzzle)
	else:
		start_puzzle({"dimensions":Vector3(3,3,3),"data":[[Vector3(0,0,0),Color(1,1,1,1)]],"hints":[[],[],[]]})

func _input(event):
	if event.is_action("break_action"):
		var is_pressed=event.is_action_pressed("break_action")
		$CanvasLayer/Container/break_button.pressed=is_pressed
		_on_break_button_toggled(is_pressed)
	elif event.is_action("paint_action"):
		var is_pressed=event.is_action_pressed("paint_action")
		$CanvasLayer/Container/paint_button.pressed=is_pressed
		_on_paint_button_toggled(is_pressed)
	elif event.is_action("build_action"):
		var is_pressed=event.is_action_pressed("build_action")
		$CanvasLayer/Container/hint_button.pressed=is_pressed
		_on_hint_button_toggled(is_pressed)

func start_puzzle(puzzle_data):
	$Manager.size=puzzle_data.dimensions
	$Manager.data=puzzle_data.data
	$Manager.visible_hints=puzzle_data.hints
	$Manager.generate=true
	game_data.game_status=game_data.HINT_EDITION
	$Manager.reset_handlers()

func _on_break_button_toggled(button_pressed):
	if button_pressed:
		game_data.touch_mode=game_data.TOUCH_DESTROY
		$CanvasLayer/Container/paint_button.pressed=false
		$CanvasLayer/Container/hint_button.pressed=false
	else:
		game_data.touch_mode=game_data.TOUCH_NORMAL


func _on_paint_button_toggled(button_pressed):
	if button_pressed:
		game_data.touch_mode=game_data.TOUCH_PAINT
		$CanvasLayer/Container/break_button.pressed=false
		$CanvasLayer/Container/hint_button.pressed=false
	else:
		game_data.touch_mode=game_data.TOUCH_NORMAL

func _on_hint_button_toggled(button_pressed):
	if button_pressed:
		game_data.touch_mode=game_data.TOUCH_HINT
		$CanvasLayer/Container/break_button.pressed=false
		$CanvasLayer/Container/paint_button.pressed=false
	else:
		game_data.touch_mode=game_data.TOUCH_NORMAL

func _on_SoundBtn_toggled(button_pressed):
	AudioServer.set_bus_mute(0,button_pressed)

func _on_Manager_hint_toggled(axis, position):
	pass # replace with function body

func _on_ResetBtn_pressed():
	$Manager.reset_cells()

func save_hints():
	game_data.current_puzzle.hints=$Manager.visible_hints
	game_data.save_to_file()


func _on_CloseBtn_pressed():
	$CanvasLayer/MenuDialog.hide()


func _on_MenuBtn_pressed():
	$CanvasLayer/MenuDialog.popup_centered()


func _on_PropertiesBtn_pressed():
	save_hints()
	get_tree().change_scene("res://PuzzleProperties.tscn")


func _on_BuildBtn_pressed():
	save_hints()
	get_tree().change_scene("res://Builder.tscn")
