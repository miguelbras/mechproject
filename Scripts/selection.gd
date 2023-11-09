# from https://godotforums.org/u/xyz, awnser:
# https://godotforums.org/d/34220-more-information-about-using-3d-selection-boxes/39

extends Area3D

@export var camera: Camera3D
const near_far_margin = .1 # frustum near/far planes distance from camera near/far planes

# mouse dragging position
var mouse_down_pos: Vector2
var mouse_current_pos: Vector2

func _ready():
	# initial reference rect setup
	$ReferenceRect.editor_only = false
	$ReferenceRect.visible = false

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			# initialize the rect when mouse is pressed
			mouse_down_pos = event.position
			mouse_current_pos = event.position
			$ReferenceRect.position = event.position
			$ReferenceRect.size = Vector2.ZERO
			$ReferenceRect.visible = true
		else:
			$ReferenceRect.visible = false
			# make a scelection when mouse is released
			select()	
	if event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_LEFT:
		# set rect size when mouse is dragged
		mouse_current_pos = event.position
		$ReferenceRect.position.x = min(mouse_current_pos.x, mouse_down_pos.x)
		$ReferenceRect.position.y = min(mouse_current_pos.y, mouse_down_pos.y)
		$ReferenceRect.size = (event.position - mouse_down_pos).abs()
		
func select():
	# get frustum mesh and assign it as a collider and assignit to the area 3d
	$ReferenceRect.size.x = max(1, $ReferenceRect.size.x)
	$ReferenceRect.size.y = max(1, $ReferenceRect.size.y)
	$CollisionShape3D.shape = make_frustum_collision_mesh(Rect2($ReferenceRect.position, $ReferenceRect.size))
	# wait for collider asignment to take effect
	await get_tree().physics_frame
	await get_tree().physics_frame
	# actually get areas that intersest the frustum
	var selection = get_overlapping_areas()
	print("SELECTION: ", selection)
	# YOUR CODE THAT DECIDES WHAT TO DO WITH THE SELECTION GOES HERE

# function that construct frustum mesh collider
func make_frustum_collision_mesh(rect: Rect2) -> ConvexPolygonShape3D:
	# create a convex polygon collision shape
	var shape = ConvexPolygonShape3D.new()
	# project 4 corners of the rect to the camera near plane
	var pnear = project_rect(rect, camera, camera.near + near_far_margin)
	# project 4 corners of the rext to the camera far plane
	var pfar = project_rect(rect, camera, camera.far - near_far_margin)
	# create a frustum mesh from 8 projected points, 6 planes, 2 triangles per plane, 3 vertices per triangle
	shape.points = PackedVector3Array([
		# near plane
		pnear[0], pnear[1], pnear[2], 
		pnear[1], pnear[2], pnear[3],
		# far plane
		pfar[2], pfar[1], pfar[0],
		pfar[2], pfar[0], pfar[3],
		#top plane
		pnear[0], pfar[0], pfar[1],
		pnear[0], pfar[1], pnear[1],
		#bottom plane
		pfar[2], pfar[3], pnear[3],
		pfar[2], pnear[3], pnear[2],
		#left plane
		pnear[0], pnear[3], pfar[3],
		pnear[0], pfar[3], pfar[0],
		#right plane
		pnear[1], pfar[1], pfar[2],
		pnear[1], pfar[2], pnear[2]
	])
	return shape

# helper function that projects 4 rect corners into space, onto a viewing plane at z distance from the given camera
# projection is done using given camera's perspective projection settings 
func project_rect(rect: Rect2, cam: Camera3D, z: float) -> PackedVector3Array:
	var p = PackedVector3Array() # our projected points
	p.resize(4)
	p[0] = cam.project_position(rect.position, z)
	p[1] = cam.project_position(rect.position + Vector2(rect.size.x, 0.0), z)
	p[2] = cam.project_position(rect.position + Vector2(rect.size.x, rect.size.y), z)
	p[3] = cam.project_position(rect.position + Vector2(0.0, rect.size.y), z)
	return p
