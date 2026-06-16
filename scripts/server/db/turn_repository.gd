class_name TurnRepository
extends RefCounted

## DatabaseManager global instance reference
var _db_manager: DatabaseManager

## Manager argument needs to be the main DatabaseManager global instance
func _init(manager: DatabaseManager):
	if not manager.is_initialized:
		return
	_db_manager = manager

# ==================== TURN FUNCTIONS ====================
func get_all() -> Array:
	_db_manager.db.query("""
		SELECT *
		FROM turn
	""")
	return _db_manager.db.query_result


func get_by_id(turn_id: int) -> Dictionary:
	_db_manager.db.query_with_bindings("""
		SELECT *
		FROM turn
		WHERE id = ?
	""", [turn_id])
	var result = _db_manager.db.query_result
	return result[0] if not result.is_empty() else {}


func create_new(match_player_id: int, order_num: int, action_num: int, action_info: String, character: int) -> Dictionary:
	var current_time = Time.get_datetime_string_from_system(true)
	_db_manager.db.query_with_bindings("""
	    INSERT INTO turn (match_player, order_num, action_num, action_info, time, character)
	    VALUES (?, ?, ?, ?, ?, ?)
		RETURNING *;
	""", [match_player_id, order_num, action_num, action_info, current_time, character])
	return _db_manager.db.query_result[0] if not _db_manager.db.query_result.is_empty() else {}


func update_by_id(match_player_arrest_id: int, character: int, points: int) -> Dictionary:
	_db_manager.db.query_with_bindings("""
	    UPDATE match_player_arrest
	    SET character = ?,
			points = ?
		WHERE id = ?
		RETURNING *;
	""", [character, points, match_player_arrest_id])
	return _db_manager.db.query_result[0] if not _db_manager.db.query_result.is_empty() else {}
