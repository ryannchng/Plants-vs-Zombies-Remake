extends CharacterBody2D

const sun_resource = preload("res://scenes/sun.tscn")

var health: int = 300
const sun_value: int = 25
const production_time: float = 24.0

func _ready():
	$SunProductionTimer.wait_time = 5.0			# change to production_time later
	get_node("SunProductionTimer").start()
	$AnimatedSprite2D.play("Idle")
	
func _on_sun_production_timer_timeout():
	produce_sun()
	
func produce_sun():
	$AnimatedSprite2D.play("Produce")
	await $AnimatedSprite2D.animation_finished
	
	$AnimatedSprite2D.play("Idle")
	get_node("SunProductionTimer").start()
