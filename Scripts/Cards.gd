extends Node

#Number of cards on board
export var width = 5
export var height = 7

#Loading external nodes and scripts
var Card = preload("res://Scenes/Card.tscn")
const Utils = preload("res://Scripts/Utils.gd")
onready var UI = get_node("/root/Main/UI")
onready var CardNode = get_node("/root/Main/Cards/Card")
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
			card.position = Vector2(j * 150, -i * 150)
			cardsArrayLineBuffer.append(card)
			self.add_child(card)
			card.getCard().coordinates = [i,j]
			
		globals.cardsArray.append(cardsArrayLineBuffer)
		
## Redraws Board after winning hand, dropping existing higher tiles into lower voids left by winning hand, 
## and generating new random cards for empty spots
func save(content):
    var file = File.new()
    file.open("user://save_game.dat", file.WRITE)
    file.store_string(content)
    file.close()

func repopulate():
	var file = File.new()
	file.open("res://cardsArrayOutput.txt", file.WRITE)
	

	for i in range(height):
		print (height - 1)
		for j in range(width):
			if (globals.cardsArray[i][j] in globals.cardsSelected):
				globals.cardsArray[i][j] = null

			if (!globals.cardsArray[i][j]):
				if (i < height - 1):

					var higher = []
					var level = i + 1
					
					while (level < height):
						if (globals.cardsArray[level][j] != null):
							print ("i: ", i, " j: ", j)
							globals.cardsArray[i][j] = globals.cardsArray[level][j]
							globals.cardsArray[i][j].getCard().coordinates = [i,j]
							globals.cardsArray[i][j].getCard().selected = false
							globals.cardsArray[level][j] = null
							break
							

				else:
					var card = Card.instance()
					globals.cardsArray[i][j] = card
					self.add_child(globals.cardsArray[i][j])
					globals.cardsArray[i][j].getCard().coordinates = [i,j]
					self.remove_child(globals.cardsArray[i][j])


	globals.cardsSelected.clear()
	
	for i in range(height):
		for j in range(width):
			file.store_line(String(globals.cardsArray[i][j].getCard()))


			
	
	file.close()
	
		
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
