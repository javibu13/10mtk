class_name MatchPlayerRepository
extends RefCounted

## DatabaseManager global instance reference
var _db_manager: DatabaseManager

## Manager argument needs to be the main DatabaseManager global instance
func _init(manager: DatabaseManager):
	if not manager.is_initialized:
		return
	_db_manager = manager

# ==================== MATCH_PLAYER FUNCTIONS ====================
func get_all() -> Array:
	_db_manager.db.query("""
		SELECT *
		FROM match_player
	""")
	return _db_manager.db.query_result


func get_by_id(match_player_id: int) -> Dictionary:
	_db_manager.db.query_with_bindings("""
		SELECT *
		FROM match_player
		WHERE id = ?
	""", [match_player_id])
	var result = _db_manager.db.query_result
	return result[0] if not result.is_empty() else {}


func create_new(match_id: int, player_id: int, character: int = 0, status: int = 0) -> Dictionary:
	_db_manager.db.query_with_bindings("""
	    INSERT INTO match_player (match, player, character, status)
	    VALUES (?, ?, ?, ?)
		RETURNING *;
	""", [match_id, player_id, character, status])
	return _db_manager.db.query_result[0] if not _db_manager.db.query_result.is_empty() else {}


func update_by_id(match_player_id: int, character: int, status: int) -> Dictionary:
	_db_manager.db.query_with_bindings("""
	    UPDATE match_player
	    SET character = ?,
			status = ?
		WHERE id = ?
		RETURNING *;
	""", [character, status, match_player_id])
	return _db_manager.db.query_result[0] if not _db_manager.db.query_result.is_empty() else {}
