extends Node2D

class_name GameManager

# Turn timer
var turn = -1

# Resources enum for referencing buildings 
enum Resources {FOOD, WATER, WALL, ARMS, INFLUENCE, MANPOWER}
var resource_names = ["Food", "Water", "Wall", "Arms", "Influence"]
var ability_risk_returns = [[8, 10], [4, 5], [12, 10], [6, 5], [12, 1], [0, 0]]

# Events
var events = [
	{
		'title': 'Food Rots!',
		'resource': Resources.FOOD,
		'amount': 15,
		'flavour': "This is some flavour text",
	},
	{
		'title': 'Water Poisoned!',
		'resource': Resources.WATER,
		'amount': 15,
		'flavour': "This is some flavour text",
	},
	{
		'title': 'Riots Break Out!',
		'resource': Resources.INFLUENCE,
		'amount': 15,
		'flavour': "This is some flavour text",
	},
	{
		'title': 'Walls Start to Crumble!',
		'resource': Resources.WALL,
		'amount': 15,
		'flavour': "This is some flavour text",
	},
	{
		'title': 'Weapons Rust',
		'resource': Resources.ARMS,
		'amount': 15,
		'flavour': "This is some flavour text",
	},
]

var active_events = {
	Resources.FOOD: null,
	Resources.WATER: null,
	Resources.WALL: null,
	Resources.ARMS: null,
	Resources.INFLUENCE: null,
	Resources.MANPOWER: null,
}

# Resources
export (int) var grain
export (int) var water
export (int) var arms
export (int) var walls
export (int) var influence

# Enemy Strength
var enemies = 0

# Manpower
var dice = 20
var turn_dice = 0
var commited_dice = 0

func _ready():
	increment_turn()
	turn_dice = dice
	commit_enemies()
	update_ui()

func process_turn():
	resolve_combat()
	commit_enemies()
	degrade_resources()
	increment_turn()
	turn_dice = dice
	update_ui()
	generate_event()

func increment_turn():
	turn += 1
	commited_dice = 0
	$HUDCanvas/BuildingInterface.on_turn_update()

func get_dice_roll():
	return randi()%6+1

func resolve_combat():
	for enemy in range(enemies):
		if commited_dice > 0:
			var player_roll = get_dice_roll()
			var enemy_roll = get_dice_roll()
			if player_roll > enemy_roll:
				enemies -= 1
				influence += 1
			elif enemy_roll > player_roll:
				commited_dice -=1
				influence -= 1
			else:
				enemies -= 1
				commited_dice -=1
		elif walls > 0:
			walls -= get_dice_roll()
		else:
			# TODO make something cool happen
			print("game over")

func commit_enemies():
	var committed = 1 + (turn / 20)
	enemies += committed

func degrade_resources():
	grain -= dice
	water -= dice
	walls -= 1

func generate_event():
	var new_event = events[randi()%events.size()]
	if not active_events[new_event['resource']]:
		active_events[new_event['resource']] = new_event
		$"HUDCanvas/EventPanel".display_event(new_event)

func update_ui():
	$HUDCanvas/ResourceBar.update_labels()
	$Buildings.display_battlefield()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		process_turn()
	if event.is_action_pressed("ui_cancel"):
		$"HUDCanvas/EventPanel".hide()

func get_event(res_id):
	return active_events[res_id]

func clear_event(resource):
	active_events[resource] = null

func add_resources(res_id, amount):
	match res_id:
		0:
			grain += amount
		1:
			water += amount
		2:
			walls += amount
		3:
			arms += amount
		4:
			influence += amount
	update_ui()
