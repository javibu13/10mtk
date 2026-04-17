class_name MatchRepository
extends RefCounted

## DatabaseManager global instance reference
var _db_manager: DatabaseManager

## Manager argument needs to be the main DatabaseManager global instance
func _init(manager: DatabaseManager):
	if not manager.is_initialized:
		return
	_db_manager = manager

# ==================== MATCH FUNCTIONS ====================
func get_all() -> Array:
	_db_manager.db.query("""
		SELECT *
		FROM match
	""")
	return _db_manager.db.query_result


func get_by_id(match_id: int) -> Dictionary:
	_db_manager.db.query_with_bindings("""
		SELECT *
		FROM match
		WHERE id = ?
	""", [match_id])
	var result = _db_manager.db.query_result
	return result[0] if not result.is_empty() else {}


func create_new(server_version: String, match_type: ServerGlobalData.LobbyType, map_display: Array[Dictionary] = []) -> Dictionary:
	# TODO: Implement asking to new users for user for login and nickname for display inside game
	_db_manager.db.query_with_bindings("""
	    INSERT INTO match (version, type, map_display)
	    VALUES (?, ?, ?)
		RETURNING *;
	""", [server_version, match_type, map_display])
	return _db_manager.db.query_result[0] if not _db_manager.db.query_result.is_empty() else {}


func update_map_display_by_id(match_id: int, new_map_display: Array[Dictionary]) -> Dictionary:
	_db_manager.db.query_with_bindings("""
	    UPDATE match
	    SET map_display = ?
		WHERE id = ?
		RETURNING *;
	""", [new_map_display, match_id])
	return _db_manager.db.query_result[0] if not _db_manager.db.query_result.is_empty() else {}
