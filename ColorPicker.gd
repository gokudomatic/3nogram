extends Container

const colors=["white","yellow","orange","red","magenta","purple","blue","cyan","green","darkgreen","brown","tan","lightgrey","gray","darkgrey","black"]
var current_gradient

signal color_changed(color)

func _ready():
	current_gradient=Gradient.new()
	current_gradient.offsets=[0]
	current_gradient.colors=[Color(1,1,1,1)]
	
	var texture=GradientTexture.new()
	texture.gradient=current_gradient
	$current_color_btn.texture_normal=texture

func _on_ColorPalette_color_selected(color):
	current_gradient.colors[0]=color
	emit_signal("color_changed",color)

func _on_current_color_btn_pressed():
	$ColorPalette.visible=not $ColorPalette.visible
