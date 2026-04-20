PRAGMA foreign_keys = ON;


CREATE TABLE IF NOT EXISTS `match` (
    `id` INTEGER PRIMARY KEY AUTOINCREMENT, 
    `start_time` DATETIME NULL,
    `end_time` DATETIME NULL,
    `version` TEXT NOT NULL, 
    `type` INTEGER NOT NULL, 
    `map_display` TEXT NOT NULL DEFAULT '{}'
);


CREATE TABLE IF NOT EXISTS `player` (
    `id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `user_name` TEXT NOT NULL UNIQUE,
    `password` TEXT NOT NULL,
    `new_password` TEXT NULL,
    `nickname` TEXT NOT NULL,
    `email` TEXT NOT NULL UNIQUE,
    `active` INTEGER NOT NULL DEFAULT 1
);


CREATE TABLE IF NOT EXISTS `match_player` (
    `id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `match` INTEGER NOT NULL,
    `player` INTEGER NOT NULL,
    `character` INTEGER NOT NULL,
    `status` TEXT NOT NULL DEFAULT 'LIVE',
    FOREIGN KEY(`match`) REFERENCES `match`(`id`) ON DELETE CASCADE,
    FOREIGN KEY(`player`) REFERENCES `player`(`id`) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS `match_player_objective` (
    `id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `match_player` INTEGER NOT NULL,
    `character` INTEGER NOT NULL,
    FOREIGN KEY(`match_player`) REFERENCES `match_player`(`id`) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS `match_player_kill` (
    `id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `match_player` INTEGER NOT NULL,
    `character` INTEGER NOT NULL,
    `points` INTEGER NOT NULL,
    FOREIGN KEY(`match_player`) REFERENCES `match_player`(`id`) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS `turn` (
    `id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `match_player` INTEGER NOT NULL,
    `order_num` INTEGER NOT NULL,
    `action_num` INTEGER NOT NULL,
    `action_info` TEXT NULL, 
    `time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `character` INTEGER NOT NULL,
    FOREIGN KEY(`match_player`) REFERENCES `match_player`(`id`) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS `match_player_arrest` (
    `id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `match_player` INTEGER NOT NULL,
    `character` INTEGER NOT NULL,
    `points` INTEGER NOT NULL,
    FOREIGN KEY(`match_player`) REFERENCES `match_player`(`id`) ON DELETE CASCADE
);


CREATE INDEX IF NOT EXISTS idx_match_type ON `match`(type);
CREATE INDEX IF NOT EXISTS idx_match_player_match ON `match_player`(`match`);
CREATE INDEX IF NOT EXISTS idx_match_player_player ON `match_player`(`player`);
CREATE INDEX IF NOT EXISTS idx_turn_match_player ON `turn`(`match_player`);
CREATE INDEX IF NOT EXISTS idx_player_active ON `player`(`active`);