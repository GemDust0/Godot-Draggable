extends Node2D

const SIZE: int = 128 # Size of the grid (not of the sprite, recommended to be the size of the sprite)

@export var min: Vector2 = Vector2.ZERO # Minimum bound
@export var max: Vector2 = Vector2.ZERO # Maximum bound

var entered: bool = false # Keep track of if mouse is inside shape
var lifted: bool = false # Keep track of whether the shape is lifted or not

func _ready() -> void:
	$Sprite/PlacementPreview.texture = $Sprite.texture

func _on_area_2d_mouse_entered() -> void:
	entered = true

func _on_area_2d_mouse_exited() -> void:
	entered = false

func _input(event: InputEvent) -> void:
	if lifted && !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		lifted = false # Unlift if is lifted and lmb is unpressed. We don't check for released as releasing the button outside the game view makes the game think it never got released
		position = $Sprite/PlacementPreview.global_position # Set position to preview position
		$Sprite/PlacementPreview.visible = false # Disable the preview
		create_tween().tween_property(self, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_ELASTIC) # Elastically tween the size to normal
	elif event is InputEventMouseMotion && lifted:
		change_pos(get_global_mouse_position()) # Change position to mouse pos
	elif event is InputEventMouseButton && entered:
		lifted = event.button_index == 1 && event.pressed # Set lifted to true if the event button is lmb and the event button was pressed
		if lifted:
			$Sprite/PlacementPreview.visible = true # Enable the preview
			change_pos(get_global_mouse_position().clamp(min, max))
			create_tween().tween_property(self, "scale", Vector2(1.075, 1.075), 0.1).set_trans(Tween.TRANS_ELASTIC) # Elastically tween the size up

func change_pos(new_pos: Vector2):
	position = new_pos.clamp(min, max) # Clamp new position to within the given bounds
	$Sprite/PlacementPreview.global_position = (position/SIZE).floor() * SIZE + Vector2(SIZE/2, SIZE/2) # Set the global position of the preview first to the position on the grid, then convert grid position to actual position
