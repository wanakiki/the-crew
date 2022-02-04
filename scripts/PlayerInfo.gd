extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func set_captain()->void:
	$Captain.show()

func set_card_signal(signal_kind : int, card_name : String)->void:
	$Card.change_card(card_name)
	$Card.show_signal(signal_kind)
