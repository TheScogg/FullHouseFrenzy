extends Node

#Globals, one each to hole selected cards, and to hold all cards
var cardsSelected = []
var cardsArray = []
var score = 30
var level = 1
var fingerDown = false

func _ready():
	set_process(true)

func _input(ev):
	if (Input.is_mouse_button_pressed(1)):
		fingerDown = true
	else:
		fingerDown = false

func getFingerDown():
	return fingerDown

func _process(delta):
	pass
#func getCardArray():
#	for row in range(cardsArray.size()):
#		print ("Row " + String(row) + ": ")
#		for card in range(cardsArray[row].size()):
#			print (cardsArray[row][card].getCard().name)
			

			


