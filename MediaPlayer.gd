extends Node

export(Array,String) var sfx_playlist

var current_music=null

var stream_players={}

func _ready():
	for sfx_file in sfx_playlist:
		var stream_player=AudioStreamPlayer.new()
		stream_player.stream=load("res://"+sfx_file+".wav")
		stream_player.bus="sfx"
		add_child(stream_player)
		stream_players[sfx_file]=stream_player

func play(id):
	if stream_players.has(id):
		stream_players[id].play()

func stop(id):
	if stream_players.has(id):
		stream_players[id].stop()

func play_music():
	$bgm.play()

func stop_music():
	$bgm.stop()

func set_music(path):
	if path!=current_music:
		current_music=path
		stop_music()
		$bgm.stream=load("res://"+path)
		play_music()
	else:
		if not $bgm.playing:
			play_music()