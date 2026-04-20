class_name Board
extends RefCounted


var tile_num: int = 16
var tile_left_count = tile_num
var sniper_tile_num: int = 8
var base_sniper_probability: float = 0.1
var sniper_left_count = sniper_tile_num
var board: Dictionary[int, Dictionary] = {}

func _init(characters_to_place: Array[int],
		   new_tile_num: int = tile_num, 
		   new_sniper_tile_num: int = sniper_tile_num, 
		   new_base_sniper_probability: float = base_sniper_probability) -> void:
	tile_num = new_tile_num
	sniper_tile_num = new_sniper_tile_num
	base_sniper_probability = new_base_sniper_probability
	# Initialize left sniper tiles counter and left tiles counter
	sniper_left_count = sniper_tile_num
	tile_left_count = tile_num
	# Creates the aux variable to store the random character to assign
	var random_character_to_place = characters_to_place.pick_random()
	# Create initial tile
	board[0] = { 0 : Tile.new(Vector2i(0, 0), random_character_to_place, _is_sniper_generated_and_update_left())}
	characters_to_place.erase(random_character_to_place)
	tile_left_count -= 1
	for tile_index in tile_left_count:
		var no_checked_board : Dictionary = board.duplicate(true)
		var tile_placed = false
		while !tile_placed:
			var column_found : bool = false
			var columns : Array
			var column : int
			while !column_found:
				# Select a column and check if it has any row. Otherwise, remove the column to avoid selecting again
				columns = no_checked_board.keys()
				column = columns.pick_random()
				if no_checked_board[column].size() == 0:
					no_checked_board.erase(column)
				else:
					column_found = true
			var rows : Array = no_checked_board[column].keys()
			var row : int = rows.pick_random()
			var available_coords: Array[Vector2i] = []
			# Check if right is free to place +(1,0)
			if (column+1 in board.keys()):
				if !(row in board[column+1].keys()):
					available_coords.append(Vector2i(column+1, row))
			else:
				available_coords.append(Vector2i(column+1, row))
			# Check if left is free to place -(1,0)
			if (column-1 in board.keys()):
				if !(row in board[column-1].keys()):
					available_coords.append(Vector2i(column-1, row))
			else:
				available_coords.append(Vector2i(column-1, row))
			# Check if up is free to place +(0,1)
			if !(row+1 in board[column].keys()):
				available_coords.append(Vector2i(column, row+1))
			# Check if up is free to place +(0,1)
			if !(row-1 in board[column].keys()):
				available_coords.append(Vector2i(column, row-1))
			# Check if free space has ben found
			if (available_coords.size() > 0):
				var new_coord = available_coords.pick_random()
				# Create square in the selected place
				if !board.has(new_coord.x):
					board[new_coord.x] = {}
				random_character_to_place = characters_to_place.pick_random()
				board[new_coord.x][new_coord.y] = Tile.new(new_coord, random_character_to_place, _is_sniper_generated_and_update_left())
				characters_to_place.erase(random_character_to_place)
				tile_left_count -= 1
				tile_placed = true
			else:
				no_checked_board[column].erase(row)


func _is_sniper_generated_and_update_left() -> bool:
	var result : bool = false
	if sniper_left_count > 0:
		var left_prob : float = 1 / (float(tile_left_count) / sniper_left_count)
		var additional_prob : float = left_prob * (1-base_sniper_probability)
		var current_prob : float = base_sniper_probability + additional_prob
		print("LeftSquares: " + str(tile_left_count) + "; LeftSnipers: " + str(sniper_left_count) + "; Prob: " + str(current_prob) + str(" (leftProb:", left_prob, " + additionalProb:", additional_prob, ")"))
		if randf() <= current_prob:
			sniper_left_count -= 1
			result = true
	print("Sniper: ", "✅" if result else "❌")
	return result


# Transform object (and its content) into a dictionary
func to_dict() -> Dictionary:
	var board_dict_tiles = {}
	for x in board.keys():
		board_dict_tiles[x] = {}
		for y in board[x].keys():
			board_dict_tiles[x][y] = board[x][y].to_dict()
	return {
		"tile_num": tile_num,
		"tile_left_count": tile_left_count,
		"sniper_tile_num": sniper_tile_num,
		"base_sniper_probability": base_sniper_probability,
		"sniper_left_count": sniper_left_count,
		"board": board_dict_tiles,
	}
