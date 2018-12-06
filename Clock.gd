tool
extends Control

export(int,5,60) var warning_time_limit=5 setget set_warning_time_limit
export(int,5,60) var gameover_time_limit=15 setget set_gameover_time_limit
export(int) var border_width=2 setget set_border_width
export(Color) var perfect_color=Color(0,0.8,0,1)
export(Color) var warning_color=Color(0.8,0.8,0,1)
export(Color) var gameover_color=Color(0.8,0,0,1)
export(Color) var border_color=Color(0.2,0.2,0.2,1)
export(float) var current_time=0 setget set_current_time

export(bool) var running=false setget set_running

signal timer_notification(status)

func _ready():
	set_process(running)
	current_time=0

func _get_minimum_size():
	return Vector2(50,50)

func _draw():
	var d_offset=self.rect_size/2
	var radius=min(d_offset.x,d_offset.y)
	draw_circle(d_offset,radius,border_color)
	draw_circle_arc_poly(d_offset,radius-border_width,0,warning_time_limit/60.0*360,perfect_color)
	draw_circle_arc_poly(d_offset,radius-border_width,warning_time_limit/60.0*360,gameover_time_limit/60.0*360,warning_color)
	draw_circle_arc_poly(d_offset,radius-border_width,gameover_time_limit/60.0*360,360,gameover_color)
	draw_time(Color(0,0,0,1),Vector2(1,1))
	draw_time(Color(1,1,1,1),Vector2(0,0))

func draw_time(color,offset):
	var value=current_time/60*360
	var angle_point = deg2rad(value - 90)
	var v=Vector2(cos(angle_point), sin(angle_point))
	var d_offset=self.rect_size/2
	var radius=min(d_offset.x,d_offset.y)-5
	draw_circle(d_offset+offset,5,color)
	draw_line(d_offset+offset,d_offset+offset+v*radius,color,2)

func draw_circle_arc_poly(center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PoolVector2Array()
	points_arc.push_back(center)
	var colors = PoolColorArray([color])
	
	for i in range(nb_points+1):
		var angle_point = deg2rad(angle_from + i * (angle_to - angle_from) / nb_points - 90)
		var v=Vector2(cos(angle_point), sin(angle_point))
		points_arc.push_back(center+v*radius)
		if points_arc.size()>=3:
			draw_polygon(points_arc, colors)

func set_warning_time_limit(value):
	if value!=null:
		warning_time_limit=value
		update()

func set_gameover_time_limit(value):
	if value!=null:
		gameover_time_limit=value
		update()

func set_border_width(value):
	if value!=null:
		border_width=value
		update()

func set_current_time(value):
	if value!=null:
		current_time=value
		update()

func set_running(value):
	if value!=null:
		running=value
		set_process(value)

func _process(delta):
	set_current_time(current_time+delta/60)
	
	var notification_status=-1
	if current_time>=warning_time_limit:
		notification_status=1
	elif current_time>=gameover_time_limit:
		notification_status=10
	
	if notification_status>=0:
		emit_signal("timer_notification",notification_status)