extends Node2D

func _ready():
	$Music.play()
	get_tree().paused = false
	set_process(true)

func _process(delta):
	$PokerChip.rotate(.5 * delta)

func _on_Play_pressed():
	$PlaySound.play()

func _on_Exit_pressed():
	get_tree().quit()

func _on_PlaySound_finished():
	get_tree().change_scene("res://Scenes/Main.tscn")
