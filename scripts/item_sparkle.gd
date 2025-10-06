class_name ItemSparkle extends Area2D

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var timer: Timer = $Timer

@export var item: Item

enum States {APPEARING, SPARKLING, DISAPPEARING, HIDDEN}
var state: States = States.APPEARING

var player_in_area: bool = false
var player: GhostPlayer

static var stateTimes: Dictionary[States, float] = {
	States.APPEARING: .5,
	States.SPARKLING: 1,
	States.DISAPPEARING: .5,
	States.HIDDEN: 4,
}

func _start():
	timer.wait_time = stateTimes[state]

func _physics_process(delta: float) -> void:
	if state == States.APPEARING: process_state(0, 1, States.SPARKLING)
	elif state == States.SPARKLING: process_state(1, 1, States.DISAPPEARING)
	elif state == States.DISAPPEARING: process_state(1, 0, States.HIDDEN)
	elif state == States.HIDDEN: process_state(0, 0, States.APPEARING)
	
	if player_in_area and player.is_on_floor() and Input.is_action_just_pressed("interact"):
		collect()

func collect():
	player.inventory.add_item(item)
		
	if(player.inventory.is_full()): return
	
	player.peck()
	monitoring = false
	player_in_area = false
	queue_free()

func process_state(from: float, to: float, next_state: States):
	var weight = 1 - timer.time_left / stateTimes[state]
	sprite.modulate.a = lerp(from, to, weight)
	
	if(weight != 1): return
	
	state = next_state
	timer.start(stateTimes[state])

func _on_body_entered(body: Node2D) -> void:
	if body is GhostPlayer:
		player = body
		player_in_area = true

func _on_body_exited(body: Node2D) -> void:
	if body is GhostPlayer:
		player = body
		player_in_area = false
