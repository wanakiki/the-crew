extends CanvasLayer

signal send_card
signal need_hint
signal show_signal

var _sorted_ids : Array = []
var _player_info : Dictionary = {}		# u_id player_info实例
var self_pos : Vector2 = Vector2(11, 593)
var four_player_pos : Array = [Vector2(10, 20), Vector2(410, 20), Vector2(810, 20)]


func _ready():
	_sorted_ids = GameManager.players.keys()
	_sorted_ids.append(get_tree().get_network_unique_id())
	_sorted_ids.sort()
	print(_sorted_ids)
	
	
	# 初始化PlayerInfo
	var player_index : int = 0
	var PlayerInfo = preload("res://scenes/PlayerInfo.tscn")
	var real_pos_array : Array = []		# 根据玩家数不同 位置数组的长度不同
	var player_count = _sorted_ids.size()
	
	# 首先找到自己在排序后数组的位置 再顺时针处理剩下的玩家
	while true:
		if _sorted_ids[player_index] == get_tree().get_network_unique_id():
			var tmp = PlayerInfo.instance()
			tmp.set_position(self_pos)
			$Players.add_child(tmp)
			_player_info[_sorted_ids[player_index]] = tmp
			break
		else:
			player_index += 1
			player_index %= player_count
	print("创建玩家面板")
	# TODO 3 5个玩家时位置设置
	
	if player_count == 3:
		pass
	elif player_count == 4:
		real_pos_array = four_player_pos
	else:
		real_pos_array = four_player_pos
	
	for pos in real_pos_array:
		player_index = player_index + 1
		player_index %= player_count
		
		if _sorted_ids[player_index] in _player_info.keys():
			break
		
		var tmp = PlayerInfo.instance()
		tmp.set_position(pos)
		$Players.add_child(tmp)
		_player_info[_sorted_ids[player_index]] = tmp



func show_message(text):
	$Message.text = text
	$Message.show()
	yield(get_tree().create_timer(2), "timeout")
	$Message.hide()

func _on_HintButton_pressed():
	emit_signal("need_hint")
	# 注意此处应该由主程序调用
	if $"../PlayerHand".give_hint("Y") == -1:
		show_message("could not give hint")
	print(get_child_count())


func _on_SendCardButton_pressed():
	var card_name = $"../PlayerHand".remove_card()
	if card_name != "":
		$"../PublicCards".add_card(card_name)
		emit_signal("send_card")


func _on_SignalButton_pressed():
	emit_signal("show_signal")
	get_tree().set_group("signal_buttons", "visible", true)


func _on_TopButton_pressed():
	show_signal(2)


func _on_MiddleButton_pressed():
	show_signal(1)


func _on_BottomButton_pressed():
	show_signal(0)
	

func show_signal(kind : int)->void:
	# 0-2对应底部到顶部编号
	get_tree().set_group("signal_buttons", "visible", false)
	# TODO 调用对应用户的展示信号函数
	rpc("sync_signal", get_tree().get_network_unique_id(), kind, $"../PlayerHand".current_card())
	print( get_tree().get_network_unique_id())
	print(_player_info)
	print(_player_info.keys())
	sync_signal(get_tree().get_network_unique_id(), kind,  $"../PlayerHand".current_card())

remote func sync_signal(id : int, signal_kind : int, card_value : String)->void:
	# 同步指定用户更新信号的动作
	_player_info[id].set_card_signal(signal_kind, card_value)

