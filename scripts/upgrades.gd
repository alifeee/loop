extends Control

var rng = RandomNumberGenerator.new()

@export var loopcounterlabel: Label
@export var whatsnextlabel: Label

@export var upgrade1slot: Control
var upgrade1: Upgrade = null
@export var upgrade2slot: Control
var upgrade2: Upgrade = null
@export var packedUpgrade: PackedScene

### find an upgrade by name from the upgrades list
### useful for upgrades which rely on others to be active
#func find_upgrade(upgrades: Array[Upgrade], name: String) -> Upgrade:
	#var index = upgrades.find_custom(func(u): u.name == name)
	#return upgrades[index] if index >=0 else null

func _ready() -> void:
	loopcounterlabel.text = str(Globals.combat_round - 1) + "/3"
	if Globals.combat_round > Globals.ROUNDS_UNTIL_PORTAL:
		whatsnextlabel.text = "ESCAPE"
	else:
		whatsnextlabel.text = "FACE NEXT LOOP"
	reset_upgrades()

func die() -> void:
	if upgrade1: upgrade1slot.remove_child(upgrade1)
	if upgrade2: upgrade2slot.remove_child(upgrade2)
	queue_free()

func reset_upgrades():
	# reset upgrades
	upgrade1 = null
	for child in upgrade1slot.get_children().duplicate():
		child.queue_free()
	upgrade2 = null
	for child in upgrade2slot.get_children().duplicate():
		child.queue_free()
		
	# get 2 random upgrades
	# first
	var upgrades_mut = Globals.upgrades.filter(
		func(u: Upgrade): return u.can_appear()
	).duplicate(true)
	print("current global upgrades: ", Globals.upgrades)
	print("current available upgrades:", upgrades_mut)
	if len(upgrades_mut) == 0:
		return
	var choice1 = upgrades_mut[rng.randi() % upgrades_mut.size()]
	upgrades_mut.erase(choice1)
	upgrade1slot.add_child(choice1)
	upgrade1 = choice1
	upgrade1.pressed.connect(func(): click_upgrade(upgrade1))
	# second
	if len(upgrades_mut) == 0:
		return
	var choice2 = upgrades_mut[rng.randi() % upgrades_mut.size()]
	upgrade2slot.add_child(choice2)
	upgrade2 = choice2
	upgrade2.pressed.connect(func(): click_upgrade(upgrade2))

func click_upgrade(upgrade: Upgrade) -> void:
	# disconnect buttons on first press
	if upgrade1:
		var conns = upgrade1.pressed.get_connections()
		for conn in conns.duplicate():
			upgrade1.pressed.disconnect(conn["callable"])
	if upgrade2:
		var conns = upgrade2.pressed.get_connections()
		for conn in conns.duplicate():
			upgrade2.pressed.disconnect(conn["callable"])
	
	# do stuff with upgrade pressed
	print("pressed upgrade! ", upgrade)
	upgrade.enable()
	# animate buttons
	if upgrade1 and upgrade == upgrade1:
		print("upgrade is first!")
		upgrade.animate_pick()
		if upgrade2: upgrade2.animate_donotpick()
	if upgrade2 and upgrade == upgrade2:
		print("upgrade is second!")
		upgrade.animate_pick()
		if upgrade1: upgrade1.animate_donotpick()
