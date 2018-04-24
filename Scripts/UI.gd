extends Node2D

signal submit
signal cancel

onready var Cards = get_node("/root/Main/Cards")
onready var UI = get_node("/root/Main/UI")
export (NodePath) var scoreLabel
export (NodePath) var pauseButton
var fxTimer = Timer.new()
var fx = "BILL"

var paused = false

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	connect("submit", Cards, "submitHand")
	connect("cancel", Cards, "clearHand")
	startScoreTimer()
	set_process(true)
	
	
	fxTimer.one_shot = true
	fxTimer.wait_time = 3
	fxTimer.connect("timeout", self, "_on_Timer_timeout")
	add_child(fxTimer)

func _process(delta):
	if (globals.cardsSelected.size() == 5 && !globals.fingerDown):
		_on_SubmitButton_pressed()
		
	
	if (globals.score <= 0):
#		get_node("/root/Main/GameOver").show()
		get_tree().change_scene("res://Scenes/GameOver.tscn")
		get_tree().paused = true
#		get_tree().reload_current_scene()

func getBoardCeiling():
	return $BoardBG.position.y
	
func displayWinningHand(hand):
	var addToScore = hand[2]
	var LosingHandSound = load("res://Assets/Audio/270476__littlerobotsoundfactory__stab-knife-00.wav")
	var WinningHandSound = load("res://Assets/Audio/140382__d-w__coins-01.wav")

	var texturePath = ("res://Assets/Art/UI/Game/" + String(hand[3]))
	var texture = load(texturePath)
	$WinningHandBanner.texture = texture
	$WinningHandTween.interpolate_property(get_node("WinningHandBanner"), "modulate", Color(1.0,1.0,1.0,0), Color(1.0,1.0,1.0,1.0), 1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$WinningHandTween.start()
	$BGTween.interpolate_property(get_node("Top"), "modulate", Color(1.0,1.0,1.0,1.0), Color(0,0,0,1.0), 1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$BGTween.start()
	$WinningHandTimer.start()
	



	
	if (addToScore > 0):
		$Sounds/HandSound.stream = WinningHandSound
	else:
		$Sounds/HandSound.stream = LosingHandSound
	
	$Sounds/HandSound.play()
	


	globals.score = globals.score + hand[2]
	$CanvasLayer/WinningHandControl/ScoreLabel.text = String(globals.score)
	
#	scoreAnimation()
#
#func scoreAnimation():
#	var scoreLabel = Label.new()
#	scoreLabel.text = "I'm a label"
#	scoreLabel.rect_position = Vector2(600,700)
#	$CanvasLayer.add_child(scoreLabel)

func _on_SubmitButton_pressed():
	emit_signal("submit")
	#(Early Development) Debug Purposes

	globals.cardsSelected.clear()

func _on_timer_timeout():

	globals.score -= 1
	$CanvasLayer/WinningHandControl/ScoreLabel.text = String(globals.score)

	
func startScoreTimer():
	var timer = Timer.new()
	timer.wait_time = 1
	timer.autostart = true
	timer.connect("timeout", self, "_on_timer_timeout")
	self.add_child(timer)






func _on_WinningHandTimer_timeout():
	$WinningHandTween.interpolate_property(get_node("WinningHandBanner"), "modulate", Color(1.0,1.0,1.0,1.0), Color(1.0,1.0,1.0,0), 1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$WinningHandTween.start()

	$BGTween.interpolate_property(get_node("Top"), "modulate", Color(0,0,0,1.0), Color(1.0,1.0,1.0,1.0), 1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$BGTween.start()


func _on_Pause_pressed():
	paused = !paused
	get_tree().paused = paused

#######################POWERUP FX CODE#########################
func powerUp(effect):
	pass

func _on_Snow_pressed():
	if (!$BoardBG/Effects/Snow/Particles2D.emitting && fxTimer.time_left == 0):
		$BoardBG/Effects/Snow/Particles2D.emitting = true
		$Sounds/SnowSound.play()
		fx = "Snow"
#		powerUp(fx)
		fxTimer.start()
	
func _on_Fire_pressed():
	if (!$BoardBG/Effects/Fire/Particles2D.emitting && fxTimer.time_left == 0):
		$BoardBG/Effects/Fire/Particles2D.emitting = true
		$Sounds/FireSound.play()
		fx = "Fire"
#		powerUp(fx)
		fxTimer.start()
		
func _on_Timer_timeout():
	if (fx == "Snow"):
		$BoardBG/Effects/Snow/Particles2D.emitting = false
		$Sounds/SnowSound.stop()
	if (fx == "Fire"):
		$BoardBG/Effects/Fire/Particles2D.emitting = false
		$Sounds/FireSound.stop()
	fxTimer.stop()
