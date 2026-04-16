class_name Player
extends RefCounted

var client_id: int
var username: String
## Used for turn order
var index: int
var kills: Array[Enums.Character] = []
var assassin: Enums.Character
var objectives: Array[Enums.Character] = []
var arrests: Array[Enums.Character] = []
var status: Enums.PlayerStatus
