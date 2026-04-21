class_name VoxelPlayer
extends CharacterBody3D

## Dunia3D-style Player Controller
## Integrates with VoxelWorld and SkeleRealms

@export var speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.002
@export var reach_distance: float = 5.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera: Camera3D = $Camera3D
@onready var skeleton: Node3D = $Skeleton

var is_looking = false
var current_block_type = "stone"

signal block_interacted(position: Vector3, block_type: String, action: String)

func _ready() -> void:
	add_to_group("player")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	print("[VoxelPlayer] Initialized with Dunia3D controls")
	
	# Connect to SkeleRealms if available
	if Engine.has_singleton("SkeleRealmsCore"):
		print("[VoxelPlayer] Connected to SkeleRealmsCore")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _physics_process(delta: float) -> void:
	handle_movement(delta)
	handle_interaction()

func handle_movement(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Handle jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
	
	# Get input direction
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	move_and_slide()

func handle_interaction() -> void:
	if Input.is_action_just_pressed("ui_select"):  # Left click - destroy block
		destroy_block()
	elif Input.is_action_just_pressed("ui_focus_next"):  # Right click - place block
		place_block()
	
	# Block type selection
	if Input.is_action_just_pressed("ui_page_up"):
		current_block_type = "grass"
		print("[VoxelPlayer] Selected block: grass")
	elif Input.is_action_just_pressed("ui_page_down"):
		current_block_type = "stone"
		print("[VoxelPlayer] Selected block: stone")
	elif Input.is_action_just_pressed("ui_home"):
		current_block_type = "dirt"
		print("[VoxelPlayer] Selected block: dirt")

func destroy_block() -> void:
	var hit_pos = raycast_block(true)
	if hit_pos != Vector3.ZERO:
		var voxel_world = get_tree().get_first_node_in_group("voxel_world")
		if voxel_world and voxel_world.has_method("set_block"):
			voxel_world.set_block(hit_pos, "")
			emit_signal("block_interacted", hit_pos, "", "destroy")
			
			# Integrate with SkeleRealms mining skill
			if Engine.has_singleton("SkeleRealmsIntegration"):
				var integration = Engine.get_singleton("SkeleRealmsIntegration")
				if integration.has_method("add_skill_xp"):
					integration.add_skill_xp("mining", 10)

func place_block() -> void:
	var hit_pos = raycast_block(false)
	if hit_pos != Vector3.ZERO:
		var voxel_world = get_tree().get_first_node_in_group("voxel_world")
		if voxel_world and voxel_world.has_method("set_block"):
			voxel_world.set_block(hit_pos, current_block_type)
			emit_signal("block_interacted", hit_pos, current_block_type, "place")
			
			# Integrate with SkeleRealms building skill
			if Engine.has_singleton("SkeleRealmsIntegration"):
				var integration = Engine.get_singleton("SkeleRealmsIntegration")
				if integration.has_method("add_skill_xp"):
					integration.add_skill_xp("building", 10)

func raycast_block(destroy: bool) -> Vector3:
	var from_pos = camera.global_position
	var to_pos = from_pos + -camera.transform.basis.z * reach_distance
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from_pos, to_pos)
	query.exclude = [self]
	
	var result = space_state.intersect_ray(query)
	if result:
		var position = result.position
		if destroy:
			# For destruction, use the hit position
			return world_to_voxel(position)
		else:
			# For placement, add normal to place adjacent
			var normal = result.normal
			var hit_voxel = world_to_voxel(position)
			return hit_voxel + Vector3i(normal.x, normal.y, normal.z).abs()
	
	return Vector3.ZERO

func world_to_voxel(world_pos: Vector3) -> Vector3i:
	return Vector3i(floor(world_pos.x), floor(world_pos.y), floor(world_pos.z))

func get_player_data() -> Dictionary:
	return {
		"position": global_position,
		"rotation": rotation,
		"camera_rotation": camera.rotation,
		"current_block": current_block_type
	}

func set_player_data(data: Dictionary) -> void:
	if data.has("position"):
		global_position = data.position
	if data.has("rotation"):
		rotation = data.rotation
	if data.has("camera_rotation"):
		camera.rotation = data.camera_rotation
	if data.has("current_block"):
		current_block_type = data.current_block
