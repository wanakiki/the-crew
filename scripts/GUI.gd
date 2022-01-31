extends CanvasLayer

signal send_card
signal need_hint
signal show_signal

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
