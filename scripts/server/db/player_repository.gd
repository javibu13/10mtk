class_name PlayerRepository
extends RefCounted

## DatabaseManager global instance reference
var _db_manager: DatabaseManager

## Manager argument needs to be the main DatabaseManager global instance
func _init(manager: DatabaseManager):
	if not manager.is_initialized:
		return
	_db_manager = manager

# ==================== PLAYER FUNCTIONS ====================
func get_all() -> Array:
	_db_manager.db.query("""
		SELECT *
		FROM player
	""")
	return _db_manager.db.query_result


func get_by_nickname(nickname: String) -> Dictionary:
	_db_manager.db.query_with_bindings("""
		SELECT *
		FROM player
		WHERE nickname = ?
	""", [nickname])
	var result = _db_manager.db.query_result
	if not result.is_empty():
		return result[0]
	else:
		return {}


func get_by_email(email: String) -> Dictionary:
	_db_manager.db.query_with_bindings("""
		SELECT *
		FROM player
		WHERE email = ?
	""", [email])
	var result = _db_manager.db.query_result
	if not result.is_empty():
		return result[0]
	else:
		return {}


func create_new(nickname: String, email: String, password_hash: String) -> Dictionary:
	# TODO: Implement asking to new users for user for login and nickname for display inside game
	_db_manager.db.query_with_bindings("""
	    INSERT INTO player (user_name, password, nickname, email)
	    VALUES (?, ?, ?, ?)
		RETURNING *;
	""", [nickname, password_hash, nickname, email])
	if not _db_manager.db.query_result.is_empty():
		return _db_manager.db.query_result[0]
	else:
		return {}


func update_password_by_id(player_id: int, password: String) -> Dictionary:
	_db_manager.db.query_with_bindings("""
	    UPDATE player
	    SET password = ?
		WHERE id = ?
		RETURNING *;
	""", [password, player_id])
	if not _db_manager.db.query_result.is_empty():
		return _db_manager.db.query_result[0]
	else:
		return {}


func update_new_password_by_id(player_id: int, new_password) -> Dictionary:
	_db_manager.db.query_with_bindings("""
	    UPDATE player
	    SET new_password = ?
		WHERE id = ?
		RETURNING *;
	""", [new_password, player_id])
	if not _db_manager.db.query_result.is_empty():
		return _db_manager.db.query_result[0]
	else:
		return {}


func get_by_login(email: String, password_hash: String):
	_db_manager.db.query_with_bindings("""
		SELECT *
		FROM player
		WHERE email = ? AND (password = ? OR new_password = ?)
	""", [email, password_hash, password_hash])
	var result = _db_manager.db.query_result
	if not result.is_empty():
		return result[0]
	else:
		return {}
