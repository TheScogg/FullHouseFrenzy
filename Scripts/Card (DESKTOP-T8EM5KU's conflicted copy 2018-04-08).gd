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

func init(row, column):
	loadCard([row, column])
	self.position = Vector2(column * 150, (-row * 150))

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process(true)
	
#	UI.connect("touch", self, "getTouch")


func getCard():
	return card

###################
func loadCard(coordinates):
	card = Utils.RandomCard(coordinates)
	position = Vector2(card.coordinates[0], card.coordinates[1])
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

