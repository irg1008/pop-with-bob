class_name WeaponManager extends Node


@export var weapons: Dictionary[int, WeaponData] = {}
@export var player: PlayerController


var current_slot: int = 0