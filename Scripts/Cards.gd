extends Node

#Number of cards on board
export var width = 5
export var height = 7
var topOrder = []
signal draw

#Loading external nodes and scripts
var Card = preload("res://Scenes/Card.tscn")
const Utils = preload("res://Scripts/Utils.gd")
onready var UI = get_node("/root/Main/UI")

signal winner

func _ready():
	connect("winner", UI, "displayWinningHand")

	populate()
	
# Iterates through all cards on board and resets to non-selected color modulation
func clearHand():
	for row in globals.cardsArray:
		for card in row:
			card.get_node("Control/Button").modulate = Color(1.0,1.0,1.0,1.0)
			card.card.selected = false


#Initial Width x Height Card Population
func populate():
	self.position = Vector2(10,get_viewport().size.y - 150)

	var padding = .25

	for i in range(height):
		var cardsArrayLineBuffer = []
		
		for j in range (width):
			var card = Card.instance()
			card.init(i,j)
			self.add_child(card)
			card.position = Vector2(j * 150, (-i * 150))


			cardsArrayLineBuffer.append(card)

#			card.getCard().coordinates = [i,j]
			
			#Setting initial (not really 'old') position for zipper fade in tween
			if (i % 2 == 0):
				card.getCard().oldPosition = Vector2((j * 150) - 800, -i * 150)
			else:
				card.getCard().oldPosition = Vector2((j * 150) + 800, -i * 150)

			card.get_node("Tween").interpolate_property(card, "position", card.getCard().oldPosition, Vector2(card.getCard().coordinates[1] * 150, card.getCard().coordinates[0] * -150), 1, Tween.TRANS_SINE , Tween.EASE_IN_OUT)
			card.get_node("Tween").start()
			
			card.getCard().oldPosition = card.position
		globals.cardsArray.append(cardsArrayLineBuffer)

	
## Redraws Board after winning hand, dropping existing higher tiles into lower voids left by winning hand, 
## and generating new random cards for empty spots
func repopulate():
	
	var oldCardsArray = []
	

	for i in range(height):
		for j in range(width):
			oldCardsArray.append(globals.cardsArray[i][j])
			if (globals.cardsArray[i][j] in globals.cardsSelected):
				globals.cardsArray[i][j] = null


	#Array to help facilitate initial positioning of newly instanced cards. 
	topOrder = [0,0,0,0,0]
	
	for i in range(height):
#		topOrder = topOrder + 1
		for j in range(width):



			if (globals.cardsArray[i][j] == null):


				if (i < height - 1):

#					var higher = []
					var level = i + 1
					
					while (level < height):

						if (globals.cardsArray[level][j] != null):
							globals.cardsArray[i][j] = globals.cardsArray[level][j]
							globals.cardsArray[level][j] = null


							break
						level += 1
	
					if (globals.cardsArray[i][j] == null):
						var card = Card.instance()
						card.init(i,j)
						globals.cardsArray[i][j] = card
#						self.add_child(globals.cardsArray[i][j])
						topOrder[j] += 1
						globals.cardsArray[i][j].getCard().oldPosition = Vector2(j * 150, -900 - (150 * topOrder[j]))
				
				#TOP ROW - seems to work correctly, remember to change -2500 to -1500
				else:
					var card = Card.instance()
					globals.cardsArray[i][j] = card
					card.init(i,j)
#					self.add_child(globals.cardsArray[i][j])
					topOrder[j] += 1
#					card.position = Vector2(j * 150, (-i * 150))
					globals.cardsArray[i][j].getCard().oldPosition = Vector2(j * 150, -900 - (150 * topOrder[j]))

					


	for card in globals.cardsSelected:
		print (card)
		$DeleteCardsTween.interpolate_property(card, "modulate", Color(1.0,1.0,0,1.0), Color(1.0,1.0,0,0.0), .5, Tween.TRANS_SINE , Tween.EASE_IN_OUT)
		$DeleteCardsTween.start()

	$RedrawTimer.wait_time = .6
	$RedrawTimer.start()
#	


func redraw():
	var cardsArray = []
	var card
	
	for i in range(height):
		for j in range(width):
			card = globals.cardsArray[i][j]
			self.add_child(card)
			print (card.getCard().oldPosition)
			card.position = card.getCard().oldPosition
#			card.getCard().oldPosition = Vector2(j * 150, -i * 150 )
			
			card.getCard().coordinates = [i,j]
			card.getCard().selected = false
#			card.position = Vector2(j * 150, -i * 150)

			card.get_node("Tween").interpolate_property(globals.cardsArray[i][j], "position", 
			card.getCard().oldPosition, Vector2(j * 150, -i * 150), 1, Tween.TRANS_SINE , Tween.EASE_IN_OUT)
#			card.get_node("Tween").playback_speed = (card.getCard().oldPosition.y - card.position.y) * -.005
			if (topOrder[j] > 0):
				print (1/float(topOrder[j]))
#				card.get_node("Tween").playback_speed = 1/float(topOrder[j]) * 3
				card.get_node("Tween").playback_speed = 2
			card.get_node("Tween").start()
			card.getCard().oldPosition = Vector2(j * 150, -i * 150)
			
			

		

	

	
		
# Finds winning hand and sends signal to UI.displayWinningHand(hand)
func submitHand():
	var winningHand = Utils.evaluateHand()
	print (winningHand)
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


#func _on_DeleteCardsTween_tween_completed(object, key):
#	self.remove_child(object)
#	$DeleteCardsTween.remove(object)
#	redraw()





func _on_RedrawTimer_timeout():
	for card in globals.cardsSelected:
		self.remove_child(card)
#	$DeleteCardsTween.remove(object)
	redraw()