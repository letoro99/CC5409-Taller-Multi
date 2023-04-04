extends RigidBody2D

var isTeleporting : bool = false
var outPortal : Portal

func transportate(in_portal: Portal, out_portal: Portal):
	isTeleporting = true
	outPortal = out_portal
	
func _integrate_forces(physics_state: PhysicsDirectBodyState2D):
	if isTeleporting:
		var exitSpeed = max(abs(linear_velocity.x), abs(linear_velocity.y))
		linear_velocity = Vector2.ZERO
		apply_central_impulse(outPortal.normal_portal * exitSpeed)
		physics_state.transform = Transform2D(0.0, outPortal.global_position)
		isTeleporting = false
