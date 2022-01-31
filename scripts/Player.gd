extends Node2D


func setup():
	var card_list = ["B2", "Y2", "B2", "Y2"]
	$CanvasLayer/PlayerHand.setup(card_list)
