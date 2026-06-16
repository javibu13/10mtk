class_name MatchPlayerKillRepository
extends RefCounted

## DatabaseManager global instance reference
var _db_manager: DatabaseManager

## Manager argument needs to be the main DatabaseManager global instance
func _init(manager: DatabaseManager):
	if not manager.is_initialized:
		return
	_db_manager = manager

# ==================== MATCH_PLAYER_KILL FUNCTIONS ====================
func get_all() -> Array:
	_db_manager.db.query("""
		SELECT *
		FROM match_player_kill
	""")
	return _db_manager.db.query_result


func get_by_id(match_player_kill_id: int) -> Dictionary:
	_db_manager.db.query_with_bindings("""
		SELECT *
		FROM match_player_kill
		WHERE id = ?
	""", [match_player_kill_id])
	var result = _db_manager.db.query_result
	return result[0] if not result.is_empty() else {}


func create_new(match_player_id: int, character: int, points: int) -> Dictionary:
	_db_manager.db.query_with_bindings("""
	    INSERT INTO match_player_kill (match_player, character, points)
	    VALUES (?, ?, ?)
		RETURNING *;
	""", [match_player_id, character, points])
	return _db_manager.db.query_result[0] if not _db_manager.db.query_result.is_empty() else {}


func update_by_id(match_player_kill_id: int, character: int, points: int) -> Dictionary:
	_db_manager.db.query_with_bindings("""
	    UPDATE match_player_kill
	    SET character = ?,
			points = ?
		WHERE id = ?
		RETURNING *;
	""", [character, points, match_player_kill_id])
	return _db_manager.db.query_result[0] if not _db_manager.db.query_result.is_empty() else {}
