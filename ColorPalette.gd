tool
extends Control

export(int) var cell_size=21
const colors=["white","yellow","orange","red","magenta","purple","blue","cyan","green","darkgreen","brown","tan","lightgray","gray","webgray","black"]

signal color_selected(color)

func _ready():
	pass

func _draw():
	var i=0
	var border_color=Color(0,0,0,1)
	for x in range(2):
		for y in range(8):
			var color_name=colors[i]
			var color=ColorN(color_name,1)
			draw_rect(Rect2((cell_size+1)*x,(cell_size+1)*y,cell_size,cell_size),color,true)
			draw_rect(Rect2((cell_size+1)*x,(cell_size+1)*y,cell_size,cell_size),border_color,false)
			i+=1

func _gui_input(event):
	if event is InputEventMouseButton:
		var coord=event.position/(cell_size+1)
		var idx=int(coord.y)+8*int(coord.x)
		var color=ColorN(colors[idx])
		emit_signal("color_selected",color)