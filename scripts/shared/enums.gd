class_name Enums
extends RefCounted

enum Character {
	POLICE_1 = -1,
	POLICE_2 = -2,
	POLICE_3 = -3,
	NONE = 0,
	COCKATOO = 1,
	WALRUS = 2,
	CAT = 3,
	SNOW_LEOPARD = 4,
	KANGAROO = 5,
	TIGER = 6,
	MOUSE = 7,
	PENGUIN = 8,
	FOX = 9,
	GIRAFFE = 10,
	WOLF = 11,
	KOALA = 12,
	DOG_DALMATIAN = 13,
	OPOSSUM = 14,
	PANDA = 15,
	CROCODILE = 16,
	
}

enum Character_Police {
	POLICE_1 = -1,
	POLICE_2 = -2,
	POLICE_3 = -3,
	NONE = 0,
}

enum TileType {
	COMMON,
	SNIPER,
}

enum PlayerStatus {
	LIVE,
	DEAD,
	ARRESTED,
}

enum Action {
	NONE,
	MOVE,
	KILL,
	ASK,
}

enum ActionNumber {
	FIRST = 1,
	SECOND = 2,
}

enum PlayerInfoPanelType {
	MAIN,
	LEFT,
	TOP,
	RIGHT,
}

enum PlayerInfoCharacterType {
	ASSASSIN,
	OBJECTIVE,
}

enum DiscoveredCharacter {
	NONE,
	ASSASSIN,
	OBJECTIVE,
}

enum GameStatus {
	STARTING,
	ACTIVE,
	ENDING,
	END,
}

const CHARACTER_INFO: Dictionary[int, Dictionary] = {
	-3: {
		"name": "Kong",
		"animal": "Gorilla",
		"profession": "Police",
		"image_path": "res://textures/characters/-3_police.png",
		"color": Color("f2f2f2ff")
	},
	-2: {
		"name": "Shenzi",
		"animal": "Hyena",
		"profession": "Police",
		"image_path": "res://textures/characters/-2_police.png",
		"color": Color("f2f2f2ff")
	},
	-1: {
		"name": "Harambe",
		"animal": "Gorilla",
		"profession": "Police",
		"image_path": "res://textures/characters/-1_police.png",
		"color": Color("f2f2f2ff")
	},
	1: {
		"name": "Featherby",
		"animal": "Cockatoo",
		"profession": "Model",
		"image_path": "res://textures/characters/1_cockatoo.png",
		"color": Color("97a66c")
	},
	2: {
		"name": "Tuskarr",
		"animal": "Walrus",
		"profession": "Sailor",
		"image_path": "res://textures/characters/2_walrus.png",
		"color": Color("6c87a6")
	},
	3: {
		"name": "Theodor",
		"animal": "Cat",
		"profession": "Cardinal",
		"image_path": "res://textures/characters/3_cat.png",
		"color": Color("9e9588")
	},
	4: {
		"name": "Frosty",
		"animal": "Snow Leopard",
		"profession": "WPBL Player",
		"image_path": "res://textures/characters/4_snow_leopard.png",
		"color": Color("b0809b")
	},
	5: {
		"name": "Joey",
		"animal": "Kangaroo",
		"profession": "Farmer",
		"image_path": "res://textures/characters/5_kangaroo.png",
		"color": Color("8db1b8")
	},
	6: {
		"name": "Rajah",
		"animal": "Tiger",
		"profession": "CEO",
		"image_path": "res://textures/characters/6_tiger.png",
		"color": Color("7fb0a5")
	},
	7: {
		"name": "Pip",
		"animal": "Mouse",
		"profession": "Waitress",
		"image_path": "res://textures/characters/7_mouse.png",
		"color": Color("c29798")
	},
	8: {
		"name": "Pingu",
		"animal": "Penguin",
		"profession": "Firefighter",
		"image_path": "res://textures/characters/8_penguin.png",
		"color": Color("767ea6")
	},
	9: {
		"name": "Ari",
		"animal": "Fox",
		"profession": "Nurse",
		"image_path": "res://textures/characters/9_fox.png",
		"color": Color("6c9e5f")
	},
	10: {
		"name": "Twiga",
		"animal": "Giraffe",
		"profession": "Tennis Pro Player",
		"image_path": "res://textures/characters/10_giraffe.png",
		"color": Color("b39f79")
	},
	11: {
		"name": "Shaki",
		"animal": "Wolf",
		"profession": "Office Worker",
		"image_path": "res://textures/characters/11_wolf.png",
		"color": Color("9187ab")
	},
	12: {
		"name": "Kaly",
		"animal": "Koala",
		"profession": "Artist",
		"image_path": "res://textures/characters/12_koala.png",
		"color": Color("c2be53")
	},
	13: {
		"name": "Dottie",
		"animal": "Dog Dalmatian",
		"profession": "Musician",
		"image_path": "res://textures/characters/13_dog_dalmatian.png",
		"color": Color("966b8e")
	},
	14: {
		"name": "Moxie",
		"animal": "Opossum",
		"profession": "Assistant",
		"image_path": "res://textures/characters/14_opossum.png",
		"color": Color("917f64")
	},
	15: {
		"name": "Bao",
		"animal": "Panda",
		"profession": "Mechanic",
		"image_path": "res://textures/characters/15_panda.png",
		"color": Color("695d4c")
	},
	16: {
		"name": "Snap",
		"animal": "Crocodile",
		"profession": "Pizza Delivery Guy",
		"image_path": "res://textures/characters/16_crocodile.png",
		"color": Color("85a848")
	}
}
