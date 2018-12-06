extends Button

var puzzle=null setget set_puzzle

signal selected(source)

export(String) var caption setget set_caption

var star_tex=preload("res://textures/star_full.png")
var star_empty_tex=preload("res://textures/star_empty.png")

func _ready():
	pass

func set_caption(value):
	if has_node("title"):
		caption=value
		$title.text=value

func set_puzzle(value):
	if has_node("LikeContainer"):
		puzzle=value
		for child in $LikeContainer.get_children():
			child.queue_free()
		for i in range(puzzle.ranks.get_median_quality()+1):
			var instance=TextureRect.new()
			instance.texture=star_tex
			instance.rect_size=Vector2(32,32)
			instance.rect_min_size=Vector2(32,32)
			instance.expand=true
			instance.stretch_mode=TextureRect.STRETCH_SCALE_ON_EXPAND
			$LikeContainer.add_child(instance)
		
		var family_friendly_tex=star_tex
		if not puzzle.ranks.get_avg_family_friendly():
			family_friendly_tex=star_empty_tex
		$FamilyFriendlyIcon.texture=family_friendly_tex

func _on_PuzzleListItem_pressed():
	emit_signal("selected",self)
