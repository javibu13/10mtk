extends Node


signal database_ready
signal database_error(error_msg)


var db: SQLite
var db_path: String = "user://game_database.db"
var is_initialized: bool = false
var player: PlayerRepository
var match_game: MatchRepository
var match_player: MatchPlayerRepository
var match_player_objective: MatchPlayerObjectiveRepository
var match_player_kill: MatchPlayerKillRepository
var match_player_arrest: MatchPlayerArrestRepository
var turn: TurnRepository


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
	
	# Initialize repositories
	_init_repositories()
	
	Log.pr("✓ Database initialized at: ", db.path)
	emit_signal("database_ready")


func _configure_database() -> void:
	# Optimizations for the server
	db.query("PRAGMA journal_mode=WAL")
	db.query("PRAGMA synchronous=NORMAL")
	db.query("PRAGMA cache_size=-64000")
	db.query("PRAGMA temp_store=MEMORY")
	db.query("PRAGMA foreign_keys=ON")


func _create_tables() -> void:
	# Get tables creation script
	var schema_path = "res://scripts/server/db_schema_SQLite.sql.txt"
	if not FileAccess.file_exists(schema_path):
		push_error("Schema path not found")
		return
	var file = FileAccess.open(schema_path, FileAccess.READ)
	var sql_content = file.get_as_text()
	file.close()
	# Execute table creation query
	db.query(sql_content)
	
	Log.pr("✓ Schema executed")


func _init_repositories() -> void:
	player = PlayerRepository.new(self)
	match_game = MatchRepository.new(self)
	match_player = MatchPlayerRepository.new(self)
	match_player_objective = MatchPlayerObjectiveRepository.new(self)
	match_player_kill = MatchPlayerKillRepository.new(self)
	match_player_arrest = MatchPlayerArrestRepository.new(self)
	turn = TurnRepository.new(self)
