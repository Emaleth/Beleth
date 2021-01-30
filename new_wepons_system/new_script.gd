"""
BASE CLASS FOR ANY WEAPON COMPONENT
"""
extends RigidBody
class_name weapon_component


# WEAPON COMPONENT TYPES #
enum TYPE {
	BODY,
	MAGAZINE,
	SIGHT,
	STOCK,
	FRONT_GRIP,
	BARREL,
	SUPPRESSOR,
	LASER
}

export (TYPE) var type 

# WEAPON COMPONENT STATS #
export var damage : float
export var accuracy : float
export var recoil : Vector3
export var fire_rate : float
export var reload_speed : float
export var max_range : float
export var magazine_cappacity : int
export var mobility : float
export var penetration : float

# CONNECTION POINT OF THE COMPONENT TO REST
export var body_connector : NodePath

# CONNECTIONS ACCEPTING NEW COMPONENTS
export var connector_1 : NodePath
export (Array, TYPE) var connector_1_accepted

export var connector_2 : NodePath
export (Array, TYPE) var connector_2_accepted

export var connector_3 : NodePath
export (Array, TYPE) var connector_3_accepted

export var connector_4 : NodePath
export (Array, TYPE) var connector_4_accepted

export var connector_5 : NodePath
export (Array, TYPE) var connector_5_accepted


