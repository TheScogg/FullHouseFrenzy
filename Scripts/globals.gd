extends Node

#Globals, one each to hole selected cards, and to hold all cards
var cardsSelected = []
var cardsArray = []
var score = 30
var level = 1
var fingerDown = false

var width = 5	
var height = 7

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
func getBoxSize():
	pass
