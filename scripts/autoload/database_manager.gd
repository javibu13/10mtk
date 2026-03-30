extends Node

var db: SQLite
var db_path: String = "user://game_database.db"
var is_initialized: bool = false

signal database_ready
signal database_error(error_msg)


# Initialize database, configure connection and try to create tables if they do not exist 
func initialize_server_database():
	if is_initialized:
		push_warning("Database is already initialized")
		return
	
	db = SQLite.new()
	db.path = db_path
	
	if not db.open_db():
		push_error("Error trying to open database")
		emit_signal("database_error", "Database cannot be opened")
		return
	
	# Configuration for the server
	_configure_database()
	
	# Table creation
	_create_tables()
	
	is_initialized = true
	print("✓ Database initialized at: ", db.path)
	emit_signal("database_ready")

func _configure_database():
	# Optimizations for the server
	db.query("PRAGMA journal_mode=WAL")
	db.query("PRAGMA synchronous=NORMAL")
	db.query("PRAGMA cache_size=-64000")
	db.query("PRAGMA temp_store=MEMORY")
	db.query("PRAGMA foreign_keys=ON")

func _create_tables():
	# Get tables creation script
	var schema_path = "res://scripts/server/db_schema_SQLite.sql"
	if not FileAccess.file_exists(schema_path):
		push_error("Schema path not found")
		return
	var file = FileAccess.open(schema_path, FileAccess.READ)
	var sql_content = file.get_as_text()
	file.close()
	# Execute table creation query
	db.query(sql_content)
	
	print("✓ Schema executed")


## ==================== PLAYER FUNCTIONS ====================
func player_get_all() -> Array:
	if not is_initialized:
		return []
	db.query("""
		SELECT *
		FROM player
	""")
	return db.query_result


func player_get_by_nickname(nickname: String) -> Dictionary:
	if not is_initialized:
		return {}
	db.query_with_bindings("""
		SELECT *
		FROM player
		WHERE nickname = ?
	""", [nickname])
	var result = db.query_result
	if not result.is_empty():
		return result[0]
	else:
		return {}


func player_get_by_email(email: String) -> Dictionary:
	if not is_initialized:
		return {}
	db.query_with_bindings("""
		SELECT *
		FROM player
		WHERE email = ?
	""", [email])
	var result = db.query_result
	if not result.is_empty():
		return result[0]
	else:
		return {}


func player_create_new(nickname: String, email: String, password_hash: String) -> Dictionary:
	# TODO: Implement asking to new users for user for login and nickname for display inside game
	if not is_initialized:
		return {}
	db.query_with_bindings("""
	    INSERT INTO player (user_name, password, nickname, email)
	    VALUES (?, ?, ?, ?)
		RETURNING *;
	""", [nickname, password_hash, nickname, email])
	if not db.query_result.is_empty():
		return db.query_result[0]
	else:
		return {}


func player_update_password_by_id(player_id: int, new_password: String) -> Dictionary:
	if not is_initialized:
		return {}
	db.query_with_bindings("""
	    UPDATE player
	    SET new_password = ?
		WHERE id = ?
		RETURNING *;
	""", [new_password, player_id])
	if not db.query_result.is_empty():
		return db.query_result[0]
	else:
		return {}

func player_get_by_login(email: String, password_hash: String):
	if not is_initialized:
		return {}
	db.query_with_bindings("""
		SELECT *
		FROM player
		WHERE email = ? AND password = ?
	""", [email, password_hash])
	var result = db.query_result
	if not result.is_empty():
		return result[0]
	else:
		return {}
