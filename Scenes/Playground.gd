extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	$TouchScreenButton/AnimationPlayer.play("SnowSpecial")
	set_process(true)

func _process(delta):
	pass


func _on_TouchScreenButton_pressed():
	print ("Button Touched")
