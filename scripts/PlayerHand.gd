extends Node2D

var _cards = []
var card_selected = false
var select_card_index = -1

const Card = preload("res://scenes/Card.tscn")

func _ready():
	setup(["B2", "Y2", "B2", "Y2"])


func _update_card_pos():
	# 更新位置
	for i in range(_cards.size()):
		var total_cards_width = _cards[i].get_width() * _cards.size() * 0.6
		_cards[i].position.x = - (total_cards_width) * 0.5 + (total_cards_width / _cards.size() * (i + 0.5))

# 添加卡片实体
func _add_card(card_data):
	var card_instance = Card.instance()
	card_instance.card_name = card_data
	$Cards.add_child(card_instance)
	_cards.append(card_instance)
	return card_instance

func setup(cards):
	# 清空原有卡 生成新卡
	for c in _cards:
		c.queue_free()
	_cards.clear()
	
	for c in cards:
		_add_card(c)
	_update_card_pos()


func _input(event):
	# 检测单击
	if event is InputEventMouseButton and event.is_pressed():
		var cur_index = -1
		# 逆向遍历 确保优先访问上层图片
		for i in range(_cards.size()-1, -1, -1):
			if _cards[i] and _cards[i].check_mouse():
				cur_index = i
				break
		move_card(cur_index)


# 删除卡牌
func remove_card()->String:
	if select_card_index == -1:
		return ""
	var card_name = _cards[select_card_index].card_name
	_cards[select_card_index].destroy()
	_cards.remove(select_card_index)
	select_card_index = -1
	_update_card_pos()
	return card_name

# 上下移动卡片
func move_card(cur_index):
	# 新选中的卡片向上移动 旧卡片缩回
	if cur_index != -1:
		# 如果已有卡片被选中
		if select_card_index != -1:
			if select_card_index == cur_index:
				_cards[cur_index].move_card()
				select_card_index = -1
			else:
				_cards[cur_index].move_card()
				_cards[select_card_index].move_card()
				select_card_index = cur_index
		else:
			_cards[cur_index].move_card()
			select_card_index = cur_index

# 给出提示牌
# 应该由主控制根据当前显示颜色进行调用 暂时直接用按钮直接触发
func give_hint(cur_color):
	var card_index = -1
	for i in range(_cards.size()):
		if _cards[i].card_name[0] == cur_color:
			card_index = i
			break
	move_card(card_index)
	return card_index
	
func current_card()->String:
	# 返回当前选中的卡牌名
	print(_cards[select_card_index].card_name)
	return _cards[select_card_index].card_name
