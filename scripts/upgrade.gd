extends Button
class_name Upgrade
## An upgrade, which must have a name
## optionally, it can have:
##   enable: function called when it is enabled
##   can_appear: function called to see if it is pickable (yet)

static var packedSelf: PackedScene = preload("res://scenes/upgrade.tscn")
@export var name_label: Label
@export var description_label: Label
@export_enum("LEFT", "RIGHT") var left_or_right
@export var name_: String
@export var description: String
var is_enabled: bool = false
var _enable_extras: Callable = func(): pass
var _can_appear_extras: Callable = func(): return true

static func newp(
	new_name: String, 
	new_description: String = "does something cool…",
	new_enable: Callable = (func(): pass),
	new_can_appear: Callable = (func(): return true)
) -> Upgrade:
	var upgrade: Upgrade = packedSelf.instantiate()
	upgrade.name_ = new_name
	upgrade.description = new_description
	upgrade._enable_extras = new_enable
	upgrade._can_appear_extras = new_can_appear
	return upgrade

func _ready() -> void:
	name_label.text = name_
	description_label.text = description

func enable() -> void:
	is_enabled = true
	_enable_extras.call()
	print("enabled upgrade: ", name_)
func can_appear() -> bool:
	return (not is_enabled) and _can_appear_extras.call()

func animate_pick():
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(
		self, "material:shader_parameter/fade_progress",
		1., 1
	)
func animate_donotpick():
	#var tween = get_tree().create_tween()
	#tween.tween_property(self, "scale", Vector2(0.8, 0.8), 2)
	pass
