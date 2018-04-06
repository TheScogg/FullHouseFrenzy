extends Node

onready var UI = get_node("/root/Main/UI")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here

	pass

static func RandomCard(coordinates):
	randomize()
	print (coordinates)
	var suits = ["Spades", "Clubs", "Diamonds", "Hearts"]
	#directory is an Array of filenames

	var number = randi() % 13 + 2
	var suit = suits[randi() % suits.size()]

	
	#Returned dictionary with all info about card (name, suit, value, etc.)
	var dict = {}
	dict["name"] = String(number) + suit
	dict["number"] = number
	dict["suit"] = suit
	dict["texture"] = String(number) + suit + ".png"
	dict["coordinates"] = coordinates
	dict["selected"] = false
	return dict

static func GetDirectory(path):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with(".") and not file.ends_with("import"):
			files.append(file)
			
	dir.list_dir_end()
	
	return files

static func evaluateHand():
	var tally = {}
	var flush = true
	

	
	#index:[Winning Hand, Quantity of Said Winning Hand]
	var winningHands = {
		0:["Royal Flush",0,500],
		1:["Straight Flush",0,250], #First Pass DONE
		2:["Four of a Kind",0, 100], #DONE
		3:["Full House",0,75], #Second Pass #DONE
		4:["Flush",0,15], #First Pass DONE
		5:["Straight",0,50], #First Pass DONE
		6:["Three of a Kind",0,25], #Fist Pass DONE
		7:["Two Pair",0,15], #Second Pass - winningHands[8][1] == 2 DONE
		8:["Pair",0,10] #First Pass DONE
	}
	#Populate tally to hold quanity of each card in submitted hand
	for i in range(2,15):
		tally[i] = 0

	#Counting number of cards of each rank
	for i in globals.cardsSelected:
		tally[i.card.number] += 1

	
	############################################################################
	#Iterating through tally to assign winning hands to winningHands, 1st Pass##
	############################################################################
	
	# First, Check for flush - all selected cards have same suit
#	if (globals.cardsSelected[0].card.suit == globals.cardsSelected[1].card.suit == globals.cardsSelected[2].card.suit == globals.cardsSelected[3].card.suit == globals.cardsSelected[4].card.suit):
#		winningHands[4][1] == 1	
	for i in range(globals.cardsSelected.size()-1):
		if (i < globals.cardsSelected.size()):
			if (globals.cardsSelected[i].card.suit != globals.cardsSelected[i+1].card.suit):
				flush = false
				

	 
	# Then, run through tally of all ranks, and assign winning hands based on results
	for rank in tally:
		#Straight
		if (rank <= 10):
			if (tally[rank] && tally[rank+1] && tally[rank+2] && tally[rank+3] && tally[rank+4]):
				winningHands[5][1] = 1
		#4 of a Kind
		if (tally[rank] == 4):
			winningHands[2][1] = 1			
		#3 of a Kind
		if (tally[rank] == 3):
			winningHands[6][1] = 1	
		#Pair
		if (tally[rank] == 2):
			winningHands[8][1] += 1
		print (rank, " : ", !tally[rank])
		
		if (flush && globals.cardsSelected.size() == 5):
			#If Straight, Straight Flush
			if (winningHands[5][1] == 1):
				winningHands[1][1] == 1
			#Flush, duplicate doesn't matter, higher hands supercede lower anyways
			winningHands[4][1] = 1
			
	############################################################################
	#Iterating through tally to assign winning hands to winningHands, 2nd Pass##
	############################################################################
	
	# If two single pairs, then winning hand is 2 Pair
	if (winningHands[8][1] == 2):

		winningHands[7][1] = 1

		
	# Full House - 2 of a Kind, and 3 of a Kind
	if (winningHands[8][1] == 1 && winningHands[6][1] == 1):
		winningHands[3][1] = 1
	
	############################################################################
			

	var hands = []
	for i in range(winningHands.size()):

		if (winningHands[i][1] > 0):
			hands.append(winningHands[i])

			break
	if (!hands.size()):
		return (["NOTHING!!!",0,-100])
		

	return hands[0]


##### HAND VALIDATION CONDITIONS ######
func flush() :
	pass
	
