extends Control

var rest_export_panel_class=preload("res://RestExportPanel.tscn")

var filter=[]
var exporters=[]

func _ready():
	create_tabs()
	fill_filter()
	for puzzle in game_data.my_puzzles.puzzles:
		filter.append(puzzle.name)
	fill_current_tab()

func _on_BackBtn_pressed():
	get_tree().change_scene("res://MyPuzzleManagement.tscn")

func _on_FilterBtn_pressed():
	$FilterDialog.popup_centered()

func create_tabs():
	for server_cfg in game_data.config.servers.values():
		var server_tab=Tabs.new()
		server_tab.set_name(server_cfg.name)
		var export_panel=rest_export_panel_class.instance()
		export_panel.set_server_cfg(server_cfg)
		server_tab.add_child(export_panel)
		$TabContainer.add_child(server_tab)
		exporters.append(export_panel)

func fill_filter():
	var container=$FilterDialog/ScrollContainer/filter_items_container
	while container.get_child_count()>0:
		var item=container.get_children()[0]
		container.remove_child(item)
		item.queue_free()
	for puzzle in game_data.my_puzzles.puzzles:
		var item=Button.new()
		item.text=puzzle.name
		item.toggle_mode=true
		item.pressed=true
		item.margin_right=375
		container.add_child(item)

func _on_CloseBtn_pressed():
	$FilterDialog.hide()
	filter=[]
	for item in $FilterDialog/ScrollContainer/filter_items_container.get_children():
		if item.pressed:
			filter.append(item.text)
	fill_current_tab()

func fill_current_tab():
	if $TabContainer.current_tab==0:
		$TabContainer/JSon/JsonEdit.text=game_data.serialize_mypuzzles(filter)
	elif $TabContainer.current_tab>0:
		var tab=$TabContainer.get_current_tab_control()
		tab.get_child(0).fill_tab(filter)
		

func _on_AllBtn_pressed():
	for item in $FilterDialog/ScrollContainer/filter_items_container.get_children():
		item.pressed=true

func _on_NoneBtn_pressed():
	for item in $FilterDialog/ScrollContainer/filter_items_container.get_children():
		item.pressed=false

func _on_TabContainer_tab_changed(tab):
	fill_current_tab()
