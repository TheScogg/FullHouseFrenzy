extends Node

#Number of cards on board
export var width = 5
export var height = 7

#Loading external nodes and scripts
var Card = preload("res://Scenes/Card.tscn")
const Utils = preload("res://Scripts/Utils.gd")
onready var UI = get_node("/root/Main/UI")
onready var CardNode = get_node("/root/Main/Cards/Card")
onready var Cards = get_node("/root/Main/Cards/")
signal winner

func _ready():
	connect("winner", UI, "displayWinningHand")
	populate()

# Iterates through all cards on board and resets to non-selected color modulation
func clearHand():
	for row in globals.cardsArray:
		print (row)
		for card in row:

			card.get_node("Control/Button").modulate = Color(1.0,1.0,1.0,1.0)
			card.getCard().selected = false
	pass


#Initial Width x Height Card Population
func populate():
	self.position = Vector2(10,get_viewport().size.y - 150)

	var padding = .25

	for i in range(height):
		var cardsArrayLineBuffer = []

		for j in range (width):
			var card = Card.instance()
			card.position = Vector2(j * 150, -i * 150)
			cardsArrayLineBuffer.append(card)
			self.add_child(card)
			card.getCard().coordinates = [i,j]

		globals.cardsArray.append(cardsArrayLineBuffer)

## Redraws Board after winning hand, dropping existing higher tiles into lower voids left by winning hand,
## and generating new random cards for empty spots
func repopulate():
	var replacement

	for i in range(height):
		for j in range (width):
			# TODO : Delete submitted cards
			if globals.cardsArray[i][j] in globals.cardsSelected:

				globals.cardsArray[i][j] = null


			if (i < height-1  && globals.cardsArray[i][j] == null):

#					globals.cardsArray[i][j].get_node("Control/Button").queue_free()

				var level = i+1
				while (level < height):
					if (globals.cardsArray[level][j] != null):
						replacement = globals.cardsArray[level][j]
						globals.cardsArray[level][j] = null
						break
					level = level + 1

				globals.cardsArray[i][j] = replacement


				globals.cardsArray[i][j].getCard().coordinates = [i,j]
				globals.cardsArray[i][j].getCard().selected = false

				print ("Replacement is ", globals.cardsArray[i][j].getCard())
#				var texturePath = ("res://Assets/Art/Cards/" + globals.cardsArray[i][j].getCard().texture)

			if (i == height-1  && globals.cardsArray[i][j] == null):
				print ("YAOLSJHKSDAFLKFDLJK")
				#Remove existing card, then add this 'card'
				var card = Card.instance()
				globals.cardsArray[i][j].queue_free()
				globals.cardsArray[i][j] = card
				Cards.add_child(globals.cardsArray[i][j])



	for i in range(height):
		for j in range (width):
			if (i < height - 1):
				var texturePath = ("res://Assets/Art/Cards/" + globals.cardsArray[i][j].getCard().texture)
				var texture = load(texturePath)
				print (globals.cardsArray[i][j].getCard().texture)
				globals.cardsArray[i][j].get_node("Control/Button").normal = texture
				globals.cardsArray[i][j].get_node("Control/Button").scale = Vector2(.25,.25)




	print ("===============")
	print (globals.cardsArray)
	print ("===============")
#	for i in range(height):
#		for j in range (width):
#			if globals.cardsArray[i][j] in globals.cardsSelected:
#
#				if (i < height - 1):
##					globals.cardsArray[i][j].get_node("Control/Button").queue_free()
#					var newCard = globals.cardsArray[i][j].getCard()
#
#					newCard.name = globals.cardsArray[i+1][j].getCard().name
#					newCard.number = globals.cardsArray[i+1][j].getCard().number
#					newCard.suit = globals.cardsArray[i+1][j].getCard().suit
#					newCard.texture = globals.cardsArray[i+1][j].getCard().texture
#					newCard.selected = false
#
#					var texturePath = ("res://Assets/Art/Cards/" + newCard.texture)
#					var texture = load(texturePath)
#					globals.cardsArray[i][j].get_node("Control/Button").normal = texture
#					globals.cardsArray[i][j].get_node("Control/Button").pressed = texture
#					globals.cardsArray[i][j].get_node("Control/Button").scale = Vector2(.25,.25)
#
#				else:
#					globals.cardsArray[i][j].loadCard(globals.cardsArray[i][j].getCard().coordinates)



	## TODO : GRAB CARD ABOVE REMOVED CARD. IF NO CARD EXISTS, THEN DO THIS BELOW
#		card.get_node("Control/Button").queue_free()
#		card.add_child(globals.cardsArray[(card.getCard().coordinates[0])+1][(card.getCard().coordinates[1])])
#		card = globals.cardsArray[(card.getCard().coordinates[0])+1][(card.getCard().coordinates[1])]
#		print (CardNode.setTexture(card))


func submitHand():
	var winningHand = Utils.evaluateHand()

	emit_signal("winner", winningHand)
	clearHand()

	# Only replace cards if an actual winning hand was found
	if (winningHand[0] != "NOTHING!!!"):
		repopulate()

#Verifies whether or not selected card is adjacent to already selected card
static func validateMove(card):

	var neighbors = []

	if (!card.coordinates[0]+1 == globals.cardsArray.size()):
		neighbors.append(globals.cardsArray[card.coordinates[0]+1][card.coordinates[1]])
	if (!card.coordinates[1]+1 == globals.cardsArray[0].size()):
		neighbors.append(globals.cardsArray[card.coordinates[0]][card.coordinates[1]+1])
	if (!card.coordinates[0] == 0):
		neighbors.append(globals.cardsArray[card.coordinates[0]-1][card.coordinates[1]])
	if (!card.coordinates[1] == 0):
		neighbors.append(globals.cardsArray[card.coordinates[0]][card.coordinates[1]-1])

	if (globals.cardsSelected.size() == 0):
		return true

	for neighbor in neighbors:
		# neighbor is globals.cardsArray[card.coordinates[0]+1][card.coordinates[1]] ...
		if (neighbor == globals.cardsSelected[-1] && neighbor.card.selected):
			return true

	return false




