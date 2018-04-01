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
	loadCard([0,0])

func getCard():
	return card

###################
func loadCard(coordinates):
	card = Utils.RandomCard(coordinates)
	setTexture(card)
	
func setTexture(card):
	var texturePath = ("res://Assets/Art/Cards/" + card.texture)
	var texture = load(texturePath)
	$Control/Button.normal = texture
	$Control/Button.pressed = texture
	$Control/Button.scale = Vector2(.25,.25)
####################

func _on_Button_pressed():
	#Will revert selectedCards to a previously selected card, can revert all the way back to the first card, but no further
	if (card.selected):
		var hand = globals.cardsSelected
		var backTo = (globals.cardsSelected.find(self))

		while (globals.cardsSelected.size() - 1 > backTo):
			globals.cardsSelected[-1].get_node("Control/Button").modulate = Color(1.0,1.0,1.0,1.0)
			globals.cardsSelected[-1].card.selected = !true
			globals.cardsSelected.pop_back()


	if (globals.cardsSelected.size() < 5 && Cards.validateMove(card) && !card.selected):
		card["selected"] = true
		$Control/Button.modulate = Color(1.0,1.0,0,1.0)
		$Control/Button.scale = Vector2(.25,.25)
		globals.cardsSelected.append(self)


## It doesn't release between the buttons or on other parts of the UI because this code will run on
## any button you're situated on, not the last button of the 5 selected cards
#func _on_Button_released():
#	if (globals.cardsSelected.size() == 5 && !Input.is_mouse_button_pressed(1)):
#		UI._on_SubmitButton_pressed()
#		print (getCard().name, " released")
