# 10mtk

10mtk is a digital adaptation of the 10' To Kill board game, rebuilt in Godot as a playable multiplayer experience.

The project focuses on bringing the original tabletop idea into a digital format with a dedicated client, server logic, account access, matchmaking, and game flow screens. It also includes support scenes for onboarding, help, settings, and credits.

## What the project includes

- A main menu and login flow
- A multiplayer server scene
- Matchmaking and shared game state management
- A how-to-play screen and credits screen
- Settings and visual/UI assets for the game experience
- Godot autoloads for database, network, authentication, matchmaking, sound, and game state management

## Project structure

- `scenes/`: Main menus, game flow, server, help, and utility scenes
- `scripts/`: Client, server, shared, and autoload logic
- `addons/`: Third-party and custom Godot plugins
- `images/`, `textures/`, `materials/`, `sounds/`, `themes/`: Art, audio, and UI resources
- `builds/`: Exported or generated build artifacts

## Running the project

Open the repository in Godot 4.5.1 and run the main scene defined in `project.godot`.

## Notes

This repository is organized as a Godot project and relies on the editor configuration, autoload singletons, and needs addons to be installed for proper functionality. Please ensure you have the required Godot version and any necessary plugins before running the project.
