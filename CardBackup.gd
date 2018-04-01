extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var Cards = preload("res://Scripts/Cards.gd")
var Utils = preload("res://Scripts/Utils.gd")
onready var UI = get_node("/root/Main/UI")
onready var CardsNode = get_node("/root/Main/Cards")

# Dictionary holding individual card properties
var card
var dragging


func _ready():

	# Called every time the node is added to the scene.
	# Initialization here
	set_process(true)
#	UI.connect("touch", self, "getTouch")
	loadCard()

	
func _process(delta):
	pass
	
#################33
func setTexture(card):
	var texturePath = ("res://Assets/Art/Cards/" + card.texture)
	var texture = load(texturePath)
	$Control/Button.normal = texture
	$Control/Button.scale = Vector2(.25,.25)
	

func loadCard():
	card = Utils.RandomCard()
	setTexture(card)

####################

func getCard():
	return card

func _on_Button_pressed():
	print (Cards.validateMove(card))
	
	#Will revert selectedCards to a previously selected card
	if (card.selected):
		var hand = globals.cardsSelected
		var backTo = (globals.cardsSelected.find(self))

		while (globals.cardsSelected.size() - 1 > backTo):
			globals.cardsSelected[-1].get_node("Control/Button").modulate = Color(1.0,1.0,1.0,1.0)
			globals.cardsSelected[-1].card.selected = !true
			globals.cardsSelected.pop_back()

		for card in globals.cardsSelected:
			print (card.card)

	
	if (globals.cardsSelected.size() < 5 && Cards.validateMove(card) && !card.selected):
		card["selected"] = true
		$Control/Button.modulate = Color(1.0,1.0,0,1.0)
		$Control/Button.scale = Vector2(.25,.25)
		globals.cardsSelected.append(self)

#	if (!Cards.validateMove(card) && !card.selected):
#		$Control/Button.modulate = Color(1.0,1.0,0,1.0)
#		UI.emit_signal("cancel")
##		globals.cardsSelected.append(self)		
#		_on_Button_pressed()
	
	
	
	