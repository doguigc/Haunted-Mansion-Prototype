extends KinematicBody

onready var meleeattack = $Meleehitbox



# How fast the player moves in meters per second.
export var speed = 14
# The downward acceleration when in the air, in meters per second squared.
export var fall_acceleration = 75

# Emitted when the player was hit by a mob.
# Put this at the top of the script.
signal hit 


var velocity = Vector3.ZERO

# Vertical impulse applied to the character upon jumping in meters per second.
export var jump_impulse = 20 

# Vertical impulse applied to the character upon bouncing over a mob in
# meters per second.
export var bounce_impulse = 16




func _physics_process(delta):
	var direction = Vector3.ZERO
	
	for index in range(get_slide_count()):
		# We check every collision that occurred this frame.
		var collision = get_slide_collision(index)
		# If we collide with a monster...
		
		if collision.collider != null and collision.collider.is_in_group("mob"):
			var mob = collision.collider
			# ...we check that we are hitting it from above.
			if Vector3.UP.dot(collision.normal) > 0.1:
				# If so, we squash it and bounce.
				mob.squash()
				velocity.y = bounce_impulse
	
	
	if Input.is_action_pressed("meleeattack"): 
		attack()
	
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
	# Jumping
	if is_on_floor() and Input.is_action_just_pressed("jump"): 
		velocity.y += jump_impulse
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		$Pivot.look_at(translation + direction, Vector3.UP) 
		
	

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	velocity.y -= fall_acceleration * delta
	velocity = move_and_slide(velocity, Vector3.UP)

func attack():
	for enemy in meleeattack.get_overlapping_bodies(): 
		if enemy.is_in_group("player"):
			print("cuerpos")
		if enemy.is_in_group("mob"): 
			print("enemigo")
			enemy.health -= 100
		if enemy.has_method("squash"): 
			print("enemigo2")
		

# And this function at the bottom.
func die():
	emit_signal("hit")
	queue_free()





func _on_Mobdetector_body_entered(body):
	die()
