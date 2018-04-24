extends Node2D

func _ready():
	set_process(true)
	$Music.play()

func _process(delta):
	$Score.rotate(.5 * delta)

func _on_MenuButton_pressed():
	reset()
	$RestartTimer.wait_time = .5
	$RestartTimer.start()

func reset():
	globals.score = 30
	globals.cardsSelected.clear()
	globals.cardsArray.clear()

func _on_RestartTimer_timeout():
	get_tree().paused = false
	get_tree().change_scene("res://Scenes/Main.tscn")

func _on_Restart_Button_pressed():
	reset()
	get_tree().change_scene("res://Scenes/TitleMenu.tscn")
