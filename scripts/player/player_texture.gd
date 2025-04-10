extends Sprite
class_name PlayerTexture

var suffix: String = "_right"
var normal_attack: bool = false
var shield_off: bool = false
var crouching_off: bool = false

export(NodePath) var animation_path
export(NodePath) var player_path

onready var animation = get_node(animation_path) if animation_path != null else null
onready var player = get_node(player_path) if player_path != null else null

func _ready():
	if animation:
		animation.connect("animation_finished", self, "on_animation_finished")

func animate(direction: Vector2) -> void:
	verify_position(direction)
	if player.attacking or player.defending or player.crouching:
		action_behavior()
	elif direction.y != 0:
		vertical_behavior(direction)
	elif player.landing == true:
		animation.play("landing")
		player.set_physics_process(false)
	else:
		horizontal_behavior(direction)

func verify_position(direction: Vector2) -> void:
	if direction.x > 0:
		flip_h = false
		suffix = "_right"
	elif direction.x < 0:
		flip_h = true
		suffix = "_left"

func action_behavior() -> void:
	if player.attacking and normal_attack:
		animation.play("attack" + suffix)
	elif player.defending and shield_off:
		animation.play("shield", -1, 0.0, true)  # Continuar enquanto o botão for pressionado
	elif player.crouching and crouching_off:
		animation.play("crouch", -1, 0.0, true)  # Continuar enquanto o botão for pressionad


func vertical_behavior(direction: Vector2) -> void:
	if direction.y > 0:
		player.landing = true
		animation.play("fall")
	elif direction.y < 0:
		animation.play("jump")

func horizontal_behavior(direction: Vector2) -> void:
	if direction.x != 0:
		animation.play("run")
	else:
		animation.play("idle")

func on_animation_finished(anim_name):
	match anim_name:
		"landing":
			player.landing = false
			player.set_physics_process(true)

		"attack_left", "attack_right":
			normal_attack = false
			player.attacking = false

		"shield":
			shield_off = false
			player.defending = false
			player.can_track_input = true

		"crouch":
			crouching_off = false
			player.crouching = false
			player.can_track_input = true
