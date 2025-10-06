extends Node

var player: GhostPlayer
var spawn_pos: Node2D

var player_dead: bool
var player_health: int
var player_hitbox: Area2D

var enemy_crow_hitbox: Area2D
var enemy_crow_attack: int

var start_pos: float
var end_pos: float
