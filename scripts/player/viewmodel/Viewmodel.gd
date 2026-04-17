extends Camera3D

@export var fps_rig : Node3D;
@export var player : CharacterBody3D;
@export var reach_ray : RayCast3D;
@export var viewmodel_reach_ray : RayCast3D;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta : float) -> void:
	fps_rig.position.x = lerp(fps_rig.position.x,0.0,delta*5);
	fps_rig.position.y = lerp(fps_rig.position.y,0.0,delta*5);
	
	fps_rig.rotation.x = lerp(fps_rig.rotation.x,0.0,delta*20);
	fps_rig.rotation.y = lerp(fps_rig.rotation.y,0.0,delta*5);
	fps_rig.rotation.z = lerp(fps_rig.rotation.z,0.0,delta*5);
	
	sway_move(Vector3(player.blend_govno.z, player.blend_govno.y, player.blend_govno.x));
	
func sway(sway_amount : Vector2) -> void:
	fps_rig.position.x -= sway_amount.x*0.00001;
	fps_rig.position.y += sway_amount.y*0.00001;
	
func sway_move(sway_amount : Vector3) -> void:
	fps_rig.rotation.x += sway_amount.x*0.002;
	fps_rig.rotation.z -= sway_amount.z*0.002;
	fps_rig.rotation.x -= sway_amount.y*0.002;
