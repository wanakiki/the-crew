extends Node2D

var card_name = "Y2"
var zoom_scale = Vector2(0.6, 0.6)
var normal_scale  = Vector2(0.5, 0.5)

onready var card_img = str("res://assets/card/", card_name, ".png")

var is_selected = false
const CLICK_TWEEN_DISTANCE = 20
const CLICK_TWEEN_TIME = 0.15


# Called when the node enters the scene tree for the first time.
func _ready():
	card_initialize()
	# $Timer.start()


func _process(_delta):
	pass


func card_initialize():
	$Sprite.texture = load(card_img)
	$SignalTop.visible = false
	$SignalMid.visible = false
	$SignalBottom.visible = false


# 0-2对应底部到顶部信号，传递其他数字则全部隐藏
func show_signal(kind):
	if kind == 0:
		$SignalBottom.visible = true
	elif kind == 1:
		$SignalMid.visible = true
	elif kind == 2:
		$SignalTop.visible = true
	else:
		$SignalTop.visible = false
		$SignalMid.visible = false
		$SignalBottom.visible = false


func destroy():
	queue_free()

func get_width():
	return $Sprite.get_rect().size.x / 2
	
# 面积减半
func shrink_card():
	$Sprite.scale.x = 0.5
	$Sprite.scale.y = 0.5

# 检查鼠标是否在卡片上
func check_mouse():
	var mouseposition = get_local_mouse_position()
	var aimpos = $Sprite.get_rect().size
	if _judge_position(mouseposition, aimpos):
		return true
	else:
		return false
		

# 向上向下移动卡片
func move_card():
	if !is_selected:
		$Tween.interpolate_property($Sprite, "position", Vector2(0, 0), Vector2(0, -CLICK_TWEEN_DISTANCE), CLICK_TWEEN_TIME, Tween.EASE_OUT)
		$Tween.start()
	else:
		$Tween.interpolate_property($Sprite, "position", Vector2(0, -CLICK_TWEEN_DISTANCE), Vector2(0, 0), CLICK_TWEEN_TIME, Tween.EASE_OUT)
		$Tween.start()
	is_selected = !is_selected

func _judge_position(mousepos, aimpos):
	if abs(mousepos.x) < aimpos.x / 2 && abs(mousepos.y) < aimpos.y / 2:
		return true
	else:
		return false

# 无用函数 ↓

func _on_Timer_timeout():
	$SignalBottom.visible = true


func zoom_in_card():
	$Tween.interpolate_property(self, "scale", scale, zoom_scale, 0.5, Tween.TRANS_QUINT)
	$Tween.start()

func zoom_out_card():
	$Tween.interpolate_property(self, "scale", scale, normal_scale, 0.5, Tween.TRANS_QUINT)
	$Tween.start()
	
func _on_Card_mouse_entered():
	zoom_in_card()


func _on_Card_mouse_exited():
	zoom_out_card()

# 无用函数 ↑
