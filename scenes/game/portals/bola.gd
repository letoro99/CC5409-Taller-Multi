class_name Props
extends RigidBody2D

var isTeleporting : bool = false
var outPortal : Portal
var diffPositon : Vector2

func transportate(in_portal: Portal, out_portal: Portal):
	isTeleporting = true
	outPortal = out_portal
	var angleNormals = out_portal.normal_portal.angle_to(in_portal.normal_portal)
	var diff = (in_portal.global_position - self.global_position).rotated(angleNormals)
	diffPositon = Vector2(out_portal.normal_portal.x * diff.x, out_portal.normal_portal.x * diff.y)
	
func _integrate_forces(physics_state: PhysicsDirectBodyState2D):
	if isTeleporting:
		var exitSpeed = max(abs(linear_velocity.x), abs(linear_velocity.y))
		linear_velocity = Vector2.ZERO
		apply_central_impulse(outPortal.normal_portal * exitSpeed)
		physics_state.transform = Transform2D(0.0, outPortal.global_position + diffPositon)
		isTeleporting = false
