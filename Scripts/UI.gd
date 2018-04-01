extends Node2D

signal submit
signal cancel

onready var Cards = get_node("/root/Main/Cards")
onready var UI = get_node("/root/Main/UI")


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	connect("submit", Cards, "submitHand")
	connect("cancel", Cards, "clearHand")
	startScoreTimer()
	set_process(true)

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func displayScore():
	pass

func displayWinningHand(hand):
	print ("SIGNAL CONNECTED")
	var addToScore = hand[2]
	$WinningHandControl/WinningHandLabel.text = hand[0].to_upper()
	print (globals.score, " + ", addToScore, " = ", globals.score + addToScore)
	globals.score = globals.score + hand[2]
	$ScoreLabel.text = String(globals.score)

#func _on_CancelButton_pressed():
#	emit_signal("cancel")
#	globals.cardsSelected.clear()

func _on_SubmitButton_pressed():
	emit_signal("submit")
	#(Early Development) Debug Purposes
	globals.cardsSelected.clear()

func _on_timer_timeout():

	globals.score -= 1
	$ScoreLabel.text = String(globals.score)
	
func startScoreTimer():
	var timer = Timer.new()
	timer.wait_time = 1
	timer.autostart = true
	timer.connect("timeout", self, "_on_timer_timeout")
	self.add_child(timer)

func _process(delta):
	if (globals.cardsSelected.size() == 5 && !globals.fingerDown):
		_on_SubmitButton_pressed()




	