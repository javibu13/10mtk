class_name Board
extends RefCounted


var tile_num: int = 16
var tile_left_count = tile_num
var sniper_tile_num: int = 8
var base_sniper_probability: float = 0.1
var sniper_left_count = sniper_tile_num
var board: Dictionary[int, Dictionary] = {}

static func server_new(characters_to_place: Array[int],
		   new_tile_num: int = 16, 
		   new_sniper_tile_num: int = 8, 
		   new_base_sniper_probability: float = 0.1) -> Board:
	var new_board: Board = Board.new()
	new_board.tile_num = new_tile_num
	new_board.sniper_tile_num = new_sniper_tile_num
	new_board.base_sniper_probability = new_base_sniper_probability
	# Initialize left sniper tiles counter and left tiles counter
	new_board.sniper_left_count = new_board.sniper_tile_num
	new_board.tile_left_count = new_board.tile_num
	# Creates the aux variable to store the random character to assign
	var random_character_to_place = characters_to_place.pick_random()
	# Create initial tile
	new_board.board[0] = { 0 : Tile.server_new(Vector2i(0, 0), random_character_to_place, new_board._is_sniper_generated_and_update_left())}
	characters_to_place.erase(random_character_to_place)
	new_board.tile_left_count -= 1
	for tile_index in new_board.tile_left_count:
		var no_checked_board : Dictionary = new_board.board.duplicate(true)
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
			if (column+1 in new_board.board.keys()):
				if !(row in new_board.board[column+1].keys()):
					available_coords.append(Vector2i(column+1, row))
			else:
				available_coords.append(Vector2i(column+1, row))
			# Check if left is free to place -(1,0)
			if (column-1 in new_board.board.keys()):
				if !(row in new_board.board[column-1].keys()):
					available_coords.append(Vector2i(column-1, row))
			else:
				available_coords.append(Vector2i(column-1, row))
			# Check if up is free to place +(0,1)
			if !(row+1 in new_board.board[column].keys()):
				available_coords.append(Vector2i(column, row+1))
			# Check if up is free to place +(0,1)
			if !(row-1 in new_board.board[column].keys()):
				available_coords.append(Vector2i(column, row-1))
			# Check if free space has ben found
			if (available_coords.size() > 0):
				var new_coord = available_coords.pick_random()
				# Create square in the selected place
				if !new_board.board.has(new_coord.x):
					new_board.board[new_coord.x] = {}
				random_character_to_place = characters_to_place.pick_random()
				new_board.board[new_coord.x][new_coord.y] = Tile.server_new(new_coord, random_character_to_place, new_board._is_sniper_generated_and_update_left())
				characters_to_place.erase(random_character_to_place)
				new_board.tile_left_count -= 1
				tile_placed = true
			else:
				no_checked_board[column].erase(row)
	return new_board


func _is_sniper_generated_and_update_left() -> bool:
	var result : bool = false
	if sniper_left_count > 0:
		var left_prob : float = 1 / (float(tile_left_count) / sniper_left_count)
		var additional_prob : float = left_prob * (1-base_sniper_probability)
		var current_prob : float = base_sniper_probability + additional_prob
		Log.pr("LeftSquares: " + str(tile_left_count) + "; LeftSnipers: " + str(sniper_left_count) + "; Prob: " + str(current_prob) + str(" (leftProb:", left_prob, " + additionalProb:", additional_prob, ")"))
		if randf() <= current_prob:
			sniper_left_count -= 1
			result = true
	Log.pr("Sniper: ", "✅" if result else "❌")
	return result


## Transform object (and its content) into a dictionary
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


## Create object using dictionary and basic data type structure
static func from_dict(new_dict: Dictionary) -> Board:
	var new_board: Board = Board.new()
	new_board.tile_num = new_dict.tile_num
	new_board.tile_left_count = new_dict.tile_left_count
	new_board.sniper_tile_num = new_dict.sniper_tile_num
	new_board.base_sniper_probability = new_dict.base_sniper_probability
	new_board.sniper_left_count = new_dict.sniper_left_count
	var board_tiles: Dictionary[int, Dictionary] = {}
	for x in new_dict.board.keys():
		board_tiles[x] = {}
		for y in new_dict.board[x].keys():
			board_tiles[x][y] = Tile.from_dict(new_dict.board[x][y])
	new_board.board = board_tiles
	return new_board


## Return the Tile where the character is placed
func get_tile_of_character(character: Enums.Character) -> Tile:
	var character_tile: Tile = null
	for x_tile in board.keys():
		for tile: Tile in board[x_tile].values():
			if character in tile.get_characters_and_police():
				character_tile = tile
				break
		if character_tile:
			break
	return character_tile


func get_tile_from_location(tile_location: Vector2i) -> Tile:
	var tile: Tile = null
	if board.has(tile_location.x):
		if board[tile_location.x].has(tile_location.y):
			tile = board[tile_location.x][tile_location.y]
	return tile


## Return all Tile in the orthogonal cross of specified size arround the character (it includes the Tile where character is placed at index 0)
func get_orthogonal_cross_tiles_of_character(character: Enums.Character, cross_size := 1) -> Array[Tile]:
	var orthogonal_cross: Array[Tile] = []
	# Get Tile where the character is placed
	var central_tile: Tile = get_tile_of_character(character)
	orthogonal_cross.append(central_tile)
	for index in range(1, cross_size+1):
		# Check if there is a tile at top and get it
		if board[central_tile.location.x].has(central_tile.location.y + index):
			orthogonal_cross.append(board[central_tile.location.x][central_tile.location.y + index])
		# Check if there is a tile at right and get it
		if board.has(central_tile.location.x + index) and board[central_tile.location.x + index].has(central_tile.location.y):
			orthogonal_cross.append(board[central_tile.location.x + index][central_tile.location.y])
		# Check if there is a tile at bottom and get it
		if board[central_tile.location.x].has(central_tile.location.y - index):
			orthogonal_cross.append(board[central_tile.location.x][central_tile.location.y - index])
		# Check if there is a tile at left and get it
		if board.has(central_tile.location.x - index) and board[central_tile.location.x - index].has(central_tile.location.y):
			orthogonal_cross.append(board[central_tile.location.x - index][central_tile.location.y])
	return orthogonal_cross


func move_character_to_tile(character: Enums.Character, tile_coords: Vector2i) -> bool:
	var objective_tile: Tile = get_tile_from_location(tile_coords)
	if not objective_tile:
		Log.error(str("Tile in objective tile location (", tile_coords, ") where character ", character, " was going to be moved does not exist"))
		return false
	var current_tile: Tile = get_tile_of_character(character)
	if not current_tile:
		Log.error(str("Character ", character, " is not found in any tile"))
		return false
	# Police or character
	var character_store_variable: String
	if character in Enums.Character_Police.values():
		character_store_variable = "polices"
	else:
		character_store_variable = "characters"
	current_tile[character_store_variable].erase(character)
	objective_tile[character_store_variable][character] = true
	return true


func remove_character(character: Enums.Character) -> bool:
	var character_tile: Tile = get_tile_of_character(character)
	if not character_tile:
		Log.error(str("Tile not found for character ", character, ". Impossible character removal"))
		return false
	# Police or character
	var character_store_variable: String
	if character in Enums.Character_Police.keys():
		character_store_variable = "polices"
	else:
		character_store_variable = "characters"
	character_tile[character_store_variable].erase(character)
	return true


func move_characters_from_tile_to_random(tile_location: Vector2i) -> void:
	var origin_tile: Tile = get_tile_from_location(tile_location)
	if not origin_tile:
		Log.error("Tile not found at location ", tile_location)
		return
	var available_board := board.duplicate_deep()
	# Remove origin tile from available_board dict to avoid its selection
	available_board[tile_location.x].erase(tile_location.y)
	if available_board[tile_location.x].is_empty():
		available_board.erase(tile_location.x)
	for character in origin_tile.get_characters_and_police():
		if available_board.is_empty():
			# If there are more characters to move from tile and all tiles has been used in previous characters, regenerate available_board and continue assigning. This is only possible if ALL characters of the game are in the same tile and one is killed
			available_board = board.duplicate_deep()
			available_board[tile_location.x].erase(tile_location.y)
			if available_board[tile_location.x].is_empty():
				available_board.erase(tile_location.x)
		# Get random tile from available_board dict
		var x: int = available_board.keys().pick_random()
		var y: int = available_board[x].keys().pick_random()
		var objective_tile: Tile = available_board[x][y]
		move_character_to_tile(character, objective_tile.location)
		# Remove used tile from available_board
		available_board[x].erase(y)
		if available_board[x].is_empty():
			available_board.erase(x)


func add_police(tile_location: Vector2i, players_number: int) -> void:
	# Check all polices that are already placed in board
	var current_polices: Array[Enums.Character] = []
	for x in board.keys():
		for y in board[x].keys():
			var tile: Tile = board[x][y]
			current_polices.append_array(tile.polices.keys())
	# Check how many players are in the match because if there are 2 players, 3 polices can be placed in board but if there are more than 2 players, only 2 polices can be placed
	if (players_number > 2 and current_polices.size() == 2) or (players_number == 2 and current_polices.size() == 3):
		# Max number of polices placed. Move police instead of adding a new one
		move_character_to_tile(current_polices.pick_random(), tile_location)
	else :
		# Add new police to the board
		var new_police: Enums.Character
		if current_polices.is_empty():
			new_police = Enums.Character.POLICE_1
		else:
			current_polices.sort()
			new_police = (current_polices[0] - 1) as Enums.Character
			if new_police < Enums.Character.POLICE_3:
				var available_polices = Enums.Character_Police.values()
				available_polices.erase(0)
				for current_police in current_polices:
					available_polices.erase(current_police)
				available_polices.sort()
				new_police = available_polices[-1]
		get_tile_from_location(tile_location).polices[new_police] = true
