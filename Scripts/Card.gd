extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var Cards = preload("res://Scripts/Cards.gd")
var Utils = preload("res://Scripts/Utils.gd")
onready var CardsNode = get_node("/root/Main/Cards")

# Dictionary holding individual card properties
var card
var row
var column


func init(row, column, cardScale):
	loadCard([row, column])
	row = row
	column = column
	$Control/Button.scale = cardScale


func _ready():
	set_process(true)


func getCard():
	return card

###################
func loadCard(coordinates):
	card = Utils.RandomCard(coordinates)
	print (card.special)
	position = Vector2(card.coordinates[0], card.coordinates[1])
	setTexture(card)
	
func setTexture(card):

	var texturePath = ("res://Assets/Art/Cards/" + card.texture)
	var texture = load(texturePath)
	$Control/Button.normal = texture
	$Control/Button.pressed = texture
	
	if (card.special):
		if (card.special == "Snow"):
			$Control/Button.modulate = Color(0.0, .5, 1, 1)
		if (card.special == "Fire"):
			$Control/Button.modulate = Color(1, 0, 0, 1)


func _on_Button_pressed():

	if (card.selected):

		var hand = globals.cardsSelected
		var backTo = (globals.cardsSelected.find(self))

		while (globals.cardsSelected.size() - 1 > backTo):
			globals.cardsSelected[-1].get_node("Control/Button").modulate = Color(1.0,1.0,1.0,1.0)
			globals.cardsSelected[-1].card.selected = !true
			globals.cardsSelected.pop_back()
	
	#if 5 cards haven't already been selected, card borders an already seleted card, card is not already selected, and animation is finished
	if (globals.cardsSelected.size() < 5 && Cards.validateMove(card) && !card.selected && CardsNode.canSelect):
		card["selected"] = true
		$Control/Button.modulate = Color(1.0,1.0,0,1.0)
		globals.cardsSelected.append(self)

