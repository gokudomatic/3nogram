extends Control

var time_matcher

func _ready():
	time_matcher = RegEx.new()
	time_matcher.compile("(\\d?\\d)")
	
	if game_data.current_puzzle==null:
		game_data.create_new_puzzle()
	load_puzzle()

func load_puzzle():
	var puzzle=game_data.current_puzzle
	$Form/NameEdit.text=puzzle.name
	$Form/DifficultyCB.select(puzzle.difficulty)
	$Form/LifesEdit.value=puzzle.lifes
	$Form/WarningTimeEdit.text=time_to_str(puzzle.warning_time_limit)
	$Form/GameoverTimeEdit.text=time_to_str(puzzle.gameover_time_limit)
	$Form/Clock.warning_time_limit=puzzle.warning_time_limit
	$Form/Clock.gameover_time_limit=puzzle.gameover_time_limit

func time_to_str(time):
	var seconds=(time-int(time))*60
	return "{0}:{1}".format(["%02d" % time,"%02d" % seconds],"{_}")

func str_to_time(text):
	var result=time_matcher.search(text)
	if result:
		return int(result.get_string(1))#+float(result.get_string(2))/60
	else:
		return 0

func _on_NameEdit_focus_exited():
	game_data.current_puzzle.name=$Form/NameEdit.text


func _on_DifficultyCB_item_selected(ID):
	game_data.current_puzzle.difficulty=ID


func _on_LifesEdit_value_changed(value):
	game_data.current_puzzle.lifes=value


func _on_WarningTimeEdit_focus_exited():
	game_data.current_puzzle.warning_time_limit=min(str_to_time($Form/WarningTimeEdit.text),game_data.current_puzzle.gameover_time_limit)
	$Form/WarningTimeEdit.text=time_to_str(game_data.current_puzzle.warning_time_limit)
	$Form/Clock.warning_time_limit=game_data.current_puzzle.warning_time_limit


func _on_GameoverTimeEdit_focus_exited():
	game_data.current_puzzle.gameover_time_limit=min(60,max(str_to_time($Form/GameoverTimeEdit.text),game_data.current_puzzle.warning_time_limit))
	$Form/GameoverTimeEdit.text=time_to_str(game_data.current_puzzle.gameover_time_limit)
	$Form/Clock.gameover_time_limit=game_data.current_puzzle.gameover_time_limit

func _on_QuitBtn_pressed():
	game_data.save_to_file()
	get_tree().change_scene("res://MyPuzzleManagement.tscn")


func _on_BuilderBtn_pressed():
	get_tree().change_scene("res://Builder.tscn")


func _on_HintBtn_pressed():
	get_tree().change_scene("res://HintEditor.tscn")
