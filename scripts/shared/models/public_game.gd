class_name PublicGame
extends RefCounted

var game_id: int
var board: Dictionary[Vector2i, Tile] = {}
var players: Array[Player] = []
var turn: Turn
