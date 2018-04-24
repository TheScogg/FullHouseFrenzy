extends Node

#Number of cards on board
export var width = 8
export var height = 12

var topOrder = []
signal draw

#Binary switch to forbit selecting tiles while they are going through the process of being replaced by new tiles
var canSelect = true

var resolution
var cardSize
var spacing
var padding
var cardScale

#Loading external nodes and scripts
var Card = preload("res://Scenes/Card.tscn")
const Utils = preload("res://Scripts/Utils.gd")
onready var UI = get_node("/root/Main/UI")

signal winner

func _enter_tree():
	pass

func _ready():
	connect("winner", UI, "displayWinningHand")
	setCardSize()
	populate()
	
# Iterates through all cards on board and resets to non-selected color modulation
func clearHand():
	for row in globals.cardsArray:
		for card in row:
			card.get_node("Control/Button").modulate = Color(1.0,1.0,1.0,1.0)
			card.card.selected = false

func populate():
	self.position = Vector2(padding.x,get_viewport().size.y - spacing.y - 200)

	# Creates all card nodes, column by column, row by row, and brings them onto the board
	for i in range(globals.height):
		var cardsArrayLineBuffer = []
		
		for j in range (globals.width):
			var card = Card.instance()
			card.init(i,j, cardScale)
			self.add_child(card)
			card.position = Vector2(j * spacing.x, (-i * spacing.y))
			cardsArrayLineBuffer.append(card)
			
			#Setting initial (not really 'old') position for zipper fade in tween
			if (i % 2 == 0):
				card.getCard().oldPosition = Vector2((j * spacing.x) - 800, -i * spacing.y)
			else:
				card.getCard().oldPosition = Vector2((j * spacing.x) + 800, -i * spacing.y)

			# Creating and starting tween for initial card entry animation
			card.get_node("Tween").interpolate_property(card, "position", card.getCard().oldPosition, 
			Vector2(card.getCard().coordinates[1] * spacing.x, card.getCard().coordinates[0] * -spacing.y), 1, Tween.TRANS_SINE , Tween.EASE_IN_OUT)
			card.get_node("Tween").start()
			
			card.getCard().oldPosition = card.position
		globals.cardsArray.append(cardsArrayLineBuffer)

	
## Redraws Board after winning hand, dropping existing higher tiles into lower voids left by winning hand, 
## and generating new random cards for empty spots
func repopulate():

	for i in range(globals.height):
		for j in range(globals.width):
			# If card was just played, erase it to make room for replacement card
			if (globals.cardsArray[i][j] in globals.cardsSelected):
				globals.cardsArray[i][j] = null


	#Array to help facilitate initial positioning of newly instanced cards, which will drop in from top of board. Purely aesthetic.
	for i in range(globals.width):
		topOrder.append(0)

	
	for i in range(globals.height):
		for j in range(globals.width):
			
			if (globals.cardsArray[i][j] == null):
				#If NOT on top row:
				if (i < globals.height - 1):
					var level = i + 1
					
					#Pulls cards from above, and nullifies said cards. Basically a sorting algorithm. 
					while (level < globals.height):
						if (globals.cardsArray[level][j] != null):
							globals.cardsArray[i][j] = globals.cardsArray[level][j]
							globals.cardsArray[level][j] = null
							break
						level += 1

				if (globals.cardsArray[i][j] == null || i == globals.height - 1):
					var card = Card.instance()
					card.init(i,j, cardScale)
					globals.cardsArray[i][j] = card
					topOrder[j] += 1
					globals.cardsArray[i][j].getCard().oldPosition = Vector2(j * spacing.x, -resolution.y - (spacing.y * topOrder[j]))

	# DELAY TACTIC - for some reason, selecting cards during redraw animation does some wonky stuff. So, I disable selecting cards during
	# this time. 
	for card in globals.cardsSelected:
		canSelect = false
		$DeleteCardsTween.interpolate_property(card, "modulate", Color(1.0,1.0,0,1.0), Color(1.0,1.0,0,0.0), .3, Tween.TRANS_SINE , Tween.EASE_IN_OUT)
		$DeleteCardsTween.start()
	
	$RedrawTimer.start()
	$RedrawTimer.wait_time = .3

func _on_RedrawTimer_timeout():
	redraw()
	canSelect = true
	
func redraw():
	var cardsArray = []
	var card

	for i in range(globals.height):
		for j in range(globals.width):
			card = globals.cardsArray[i][j]
			
			if not card in self.get_children():
				self.add_child(card)

			card.position = card.getCard().oldPosition
			
			card.getCard().coordinates = [i,j]
			card.getCard().selected = false

			card.get_node("Tween").interpolate_property(globals.cardsArray[i][j], "position", 
			card.getCard().oldPosition, Vector2(j * spacing.x, -i * spacing.y), 1, Tween.TRANS_SINE , Tween.EASE_IN_OUT)

			card.get_node("Tween").start()
			
			card.getCard().oldPosition = Vector2(j * spacing.x, -i * spacing.y)
			
	topOrder.clear()
			
func setCardSize():
	resolution= Vector2(ProjectSettings.get_setting("display/window/size/width"), ProjectSettings.get_setting("display/window/size/height")
	- UI.get_node("BoardBG").position.y - 246)

	#width is actual width of card, (width+1) / X where X is a gutter 1/Xth the size of the cards
	cardSize = Vector2((resolution.x / (float(globals.width) + float(globals.width+1) / 7)), 
	(resolution.y / (float(globals.height) + float(globals.height+1) / 7)))

	padding = Vector2(cardSize.x / 7, cardSize.y / 7)
	spacing = Vector2(cardSize.x + padding.x, cardSize.y + padding.y)
	
	#Maximum size of card divided by actual size of card texture
	cardScale = Vector2(cardSize.x / 512, cardSize.y/512)	

# Finds winning hand and sends signal to UI.displayWinningHand(hand)
func submitHand():
	var winningHand = Utils.evaluateHand()
	emit_signal("winner", winningHand)
	clearHand()
	
	# Only replace cards if an actual winning hand was found
	if (winningHand[0] != "NOTHING!!!"):
		repopulate()
	#Increment special powerup quantities if special card in hand
	for card in globals.cardsSelected:
		if (card.card.special == "Snow"):
			UI.get_node("BottomBar/Buttons/Snow/Quantity").text = String(1)


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

func _on_DeleteCardsTween_tween_completed(object, key):
	object.queue_free()
