extends Node

const SCREEN_SIZE = Vector2(320, 240)

const DEFAULT_PORT = 10567
const MAX_PLAYER = 5
var peer = null

# BGPY代表四种颜色，火箭牌用A代替
const CARD_DATA = ['B1', 'B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8', 'B9', 'G1', 'G2', 'G3', 'G4', 'G5', 'G6', 'G7', 'G8', 'G9', 'P1', 'P2', 'P3', 'P4', 'P5', 'P6', 'P7', 'P8', 'P9', 'Y1', 'Y2', 'Y3', 'Y4', 'Y5', 'Y6', 'Y7', 'Y8', 'Y9', 'A1', 'A2', 'A3', 'A4']


# 用户列表
var player_name = "myself"
var players = {}
var players_ready = []

# GUI辅助信号
signal player_list_changed()
signal connection_failed()
signal connection_succeeded()
signal game_ended()
signal game_error(what)

# 网络回调函数
func _player_connected(id)->void:
	# 向新增用户注册当前用户名
	rpc_id(id, "register_player", player_name)
	return 

func _player_disconnected(id)->void:
	# 根据游戏的运行状态决定是否停止游戏
	if has_node("/root/Table"):
		if get_tree().is_network_server():
			emit_signal("game_error", "Player " + players[id] + " disconnected")
			end_game()
	else:
		# 如果没有运行则正常取消注册用户
		unregister_player(id)

# 仅在客户端运行的回调函数
func _connected_ok()->void:
	emit_signal("connection_succeeded")

func _server_disconnected()->void:
	emit_signal("game_error", "Server disconnected")
	end_game()
	
func _connected_fail()->void:
	get_tree().set_network_peer(null)	# 删除peer
	emit_signal("connection_failed")


# 大厅管理函数

remote func register_player(new_player_name)->void:
	var id = get_tree().get_rpc_sender_id()
	players[id] = new_player_name
	emit_signal("player_list_changed") 

func unregister_player(id)->void:
	players.erase(id)
	emit_signal("player_list_changed")

remote func pre_start_game(cards : Array)->void:
	# 改变当前场景
	# 新增桌面节点 隐藏大厅节点 并创建用户信息区域、初始化角色状态和卡牌
	# 调用服务器ready_to_start函数
	print(cards)
	
	# 添加游戏场景并隐藏大厅
	var table = load("res://scenes/Game.tscn").instance()
	get_tree().get_root().add_child(table)
	get_tree().get_root().get_node("Lobby").hide()
	
	# 初始化手牌
	table.get_node("PlayerHand").setup(cards)
	
	# TODO 根据用户手牌是否包含black4决定是否启用出牌按钮 并分配领航员
	if get_tree().is_network_server():
		get_node("/root/Table/GUI/SendCardButton").set_disabled(false)

	# 向服务器汇报客户端已准备好 如果只有一个玩家则直接开始游戏
	if not get_tree().is_network_server():
		rpc_id(1, "ready_to_start", get_tree().get_network_unique_id())
	elif players.size() == 0:
		# TODO 删除单用户测试代码
		table.get_node("PlayerHand").setup(cards.slice(0, 9))
		post_start_game()
	

remote func post_start_game()->void:
	# 取消暂停并释放游戏
	get_tree().set_pause(false)

remote func ready_to_start(id)->void:
	# 仅在服务端调用 接受其他人的准备信号
	assert(get_tree().is_network_server())
	
	if not id in players_ready:
		players_ready.append(id)
	
	if players_ready.size() == players.size():
		for p in players:
			rpc_id(p, "post_start_game")
		post_start_game()

func host_game(new_player_name)->void:
	player_name = new_player_name
	peer = NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT, MAX_PLAYER)
	get_tree().set_network_peer(peer)

func join_game(ip, new_player_name)->void:
	player_name = new_player_name
	peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(peer)

func get_player_list()->Array:
	return players.values()

func get_player_name()->String:
	return player_name

func begin_game()->void:
	# 服务器发牌
	assert(get_tree().is_network_server())
	
	# 洗牌并对卡牌数组进行切片
	var shuffled_cards : Array = shuffle_cards()
	var player_count = len(players) + 1
	var card_num = len(shuffled_cards) / player_count

	var index = 0
	for id in players:
		rpc_id(id, "pre_start_game", shuffled_cards.slice(index, index + card_num))
		print(shuffled_cards.slice(index, index + card_num - 1))
		index += card_num
	pre_start_game(shuffled_cards.slice(index, index + card_num - 1))
	

func end_game()->void:
	if has_node("/root/Table"):
		get_node("/root/Table").queue_free()
	emit_signal("game_ended")
	players.clear()
	

		
# 洗牌函数
func shuffle_cards() -> Array:
	var res : Array = CARD_DATA
	for i in range(39, -1, -1):
		var index = randi() % (i + 1)
		var tmp = res[index]
		res[index] = res[i]
		res[i] = tmp
	print(res)
	return res


func _ready()->void:
	# 连接信号
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
