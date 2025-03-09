extends Node2D

@export var pea_scene: PackedScene  # Reference to the Pea projectile scene

@onready var sprite = $Sprite
@onready var shooting_timer = $ShootingTimer
@onready var muzzle = $Muzzle

func _ready():
	shooting_timer.timeout.connect(shoot)
	shooting_timer.start()  # Start shooting timer

func shoot():
	sprite.play("shoot")  # Play shooting animation
	var pea = pea_scene.instantiate() as Node2D
	get_parent().add_child(pea)  # Add projectile to the main scene
	pea.global_position = muzzle.global_position  # Spawn at muzzle
