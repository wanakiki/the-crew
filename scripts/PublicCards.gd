extends Node2D


const Card = preload("res://scenes/Card.tscn")

var _public_cards : Dictionary = {}
var _sorted_ids : Array = []
var first_card : String = ""

# 构建公共卡牌区域 为方便集成功能专门独立

# Called when the node enters the scene tree for the first time.
func _ready():
	_sorted_ids = GameManager.players.keys()
	_sorted_ids.append(get_tree().get_network_unique_id())
	_sorted_ids.sort()

func _on_Button_pressed():
	# 场景测试
	add_card("A1")
	print(1)
	pass

func _update_card_pos():
	# 更新卡牌位置
	var cards : Array = $Cards.get_children()
	var total_cards_witdh : float = cards[0].get_width() * cards.size() * 1.2
	for i in range(cards.size()):
		cards[i].position.x = - (total_cards_witdh) * 0.5 + (total_cards_witdh / cards.size()) * (i + 0.5)

remotesync func new_round()->void:
	# 开启新回合
	# 清空数据
	# 展示上轮出牌
	var old_cards : Array = _public_cards.values()
	
	_public_cards.clear()
	first_card = ""
	
	# 删除目前已添加的所有卡牌实例
	var cards : Array = $Cards.get_children()
	for c in cards:
		c.queue_free()
	
	cards.clear()
	cards = $LastRound.get_children()
	for c in cards:
		c.queue_free()
	
	# 增加旧卡牌
	for c in old_cards:
		var card_instance = Card.instance()
		card_instance.card_name = c
		$LastRound.add_child(card_instance)
	
	# 调整旧卡牌位置及大小
	cards.clear()
	cards = $LastRound.get_children()
	var total_card_width : float = cards[0].get_width() * 0.5 * cards.size() * 0.5
	for i in range(cards.size()):
		cards[i].position.x = - (total_card_width) * 0.5 + (total_card_width / cards.size()) * (i + 0.5)
		cards[i].position.y = 100
		cards[i].shrink_card()
	
	
func calculate_winner()->int:
	# 根据公共卡牌情况计算最大卡牌
	var cards : Array = _public_cards.values()
	var max_card : String = first_card
	for c in cards:
		# 如果是黑色或者和首个卡牌同色则进行判断
		if c[0] == 'A':
			if max_card[0] != 'A' or (max_card[0] == 'A' and max_card[1] < c[1]):
				max_card = c
		elif c[0] == max_card[0]:
			if c[1] > max_card[1]:
				max_card = c
	
	# 找到最大卡牌对应id并返回
	for id in _sorted_ids:
		if _public_cards[id] == max_card:
			return id
	return 1

remote func revert_button()->void:
	# 翻转发牌按钮启用状态
	if $"../GUI/SendCardButton".is_disabled():
		$"../GUI/SendCardButton".set_disabled(false)
	else:
		$"../GUI/SendCardButton".set_disabled(true)


remote func change_player(id : int)->void:
	# 判断是否所有人均已出牌 计算下一个出牌人
	# 关闭发牌者出牌按钮 启用下一人出牌按钮
	# TODO 出牌结束时进入选择菜单
	
	# 查找下一位出牌人
	var next_player : int = 0
	if len(_public_cards) == len(_sorted_ids):
		next_player = calculate_winner()
		# 出牌已满 删除当前回合数据开启新回合（需要在所有节点执行）
		rpc("new_round")
	else:
		# 如果出牌数不足则顺序查找下一位出牌人
		var index : int = 0
		var flag : bool = false
		while true:
			if _sorted_ids[index] == id:
				flag = true
			index = index + 1
			index %= len(_sorted_ids)
			
			if flag	:
				next_player = _sorted_ids[index]
				break
	
	# 关闭出牌者按钮并激活下一位出牌人按钮
	# 由于rpc_id不能对自己进行调用 需要特别判断
	if id == 1:
		revert_button()
	else:
		rpc_id(id, "revert_button")
	
	if next_player == 1:
		revert_button()
	else:
		rpc_id(next_player, "revert_button")
	
	
remotesync func synccard(card_data : String, id : int)->void:
	# 添加当前用户卡牌
	if first_card == "":
		first_card = card_data
	var card_instance = Card.instance()
	card_instance.card_name = card_data
	$Cards.add_child(card_instance)
	_public_cards[id] = card_data
	
	_update_card_pos()
	
# 添加卡片实体
func add_card(card_data : String):
	# 添加卡牌并切换用户
	rpc("synccard", card_data, get_tree().get_network_unique_id())
	print("finish sync")
	
	if get_tree().is_network_server():
		change_player(1)
	else:
		rpc_id(1, "change_player", get_tree().get_network_unique_id())
