extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var sensitivity = 0.1

# cam look
var minLookAngle : float = -90.0
var maxLookAngle : float = 90.0
var lookSensitivity : float = 10.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var mouseDelta : Vector2 = Vector2()

@onready var camera : Camera3D = $Camera3D
@onready var pistol_animation : AnimationPlayer = $Camera3D/fps_pistol_animated2/AnimationPlayer
@onready var shoot_sound : AudioStreamPlayer3D = $ShootSound
@onready var reload_sound : AudioStreamPlayer3D = $ReloadSound

func _ready():
	# Hide the mouse cursor when in the game
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("strafe_left", "strafe_right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
func _process(delta: float) -> void:
	
	# rotate the camera along the x axis
	camera.rotation_degrees.x -= mouseDelta.y * lookSensitivity * delta
	
	# clamp camera x rotation axis
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, minLookAngle, maxLookAngle)
	
	# rotate the player along their y axis
	rotation_degrees.y -= mouseDelta.x * lookSensitivity * delta
	
	# reset the mouse delta vector
	mouseDelta = Vector2()
	
	if Input.is_action_just_pressed("reload"):
		if !pistol_animation.is_playing():
			#pistol_animation.play("reload")
			#pistol_animation.seek(0.3, true)
			pistol_animation.play("reload2")
			pistol_animation.seek(2.1667, true)
			reload_sound.play()
	
	if Input.is_action_just_pressed("shoot"):
		if !pistol_animation.is_playing():
			pistol_animation.play("shoot")
			pistol_animation.seek(7.5, true)
			shoot_sound.play()
	
func _input(event):
	
	if event is InputEventMouseMotion:
		mouseDelta = event.relative
