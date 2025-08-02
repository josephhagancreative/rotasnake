# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is "Rotasnake" - a Godot 4.4 snake game with unique rotation-based movement mechanics. The snake can move in straight lines or rotate in place, creating a distinctive gameplay experience compared to traditional grid-based snake games.

## Development Commands

### Running the Project
- Open the project in Godot Editor by loading `project.godot`
- Press F5 or click "Play" to run the game
- Press F6 to run the current scene

### Project Configuration
- Main scene: `Snake.tscn` (project.godot:14)
- Godot version: 4.4 with GL Compatibility renderer
- Display: 1024x600 viewport with canvas_items stretch mode
- Default gravity disabled (2D physics)

## Core Architecture

### Game Management
- **GameManager.gd**: Singleton autoload managing level progression
  - Tracks current level (1-10) and completion state
  - Handles level loading and transitions
  - Provides restart functionality
  - Auto-advances to next level after completion

### Snake System
- **snake.gd**: Main character controller with dual movement states
  - `State.MOVING`: Linear movement in cardinal directions
  - `State.ROTATING`: Circular rotation around a center point
  - Advanced input buffering system for responsive controls
  - Position history tracking for smooth tail following
  - Self-collision detection via HeadArea

### Level Structure
- **BaseLevel.gd**: Abstract base class for all levels
  - Handles snake spawning at configurable start position
  - Goal detection and level completion
  - Death handling with visual feedback
  - Input handling for restart (SPACE) and quit (ESC)

### Game Objects
- **TailSegment.gd**: Individual tail segments that follow the snake head
- **Goal.gd**: Level completion targets with pulsing animation
- **MovingObstacle.gd**: Dynamic hazards with configurable movement patterns

## Physics Layers

The game uses a 6-layer collision system:
1. `snake_head` - Snake head collision detection
2. `snake_tail` - Tail segments for self-collision
3. `walls` - Static level boundaries and obstacles
4. `hazards` - Moving obstacles that kill the snake
5. `collectibles` - Items that can be picked up
6. `goal` - Level completion triggers

## Input System

- WASD or Arrow Keys for movement
- Input priority queue system ensures latest input takes precedence
- Smooth state transitions between moving and rotating
- SPACE/ENTER: Restart level when dead
- ESC: Quit game

## Scene Organization

### Root Scenes
- `Snake.tscn`: Main game scene with snake prefab
- `BaseLevel.tscn`: Level template scene
- `TailSegment.tscn`: Snake tail segment prefab
- `MovingObstacle.tscn`: Dynamic obstacle prefab
- `Goal.tscn`: Level goal prefab

### Level Scenes
- Located in `levels/` directory
- `Level1.tscn` through `Level3.tscn` currently implemented
- Each extends BaseLevel with custom geometry and challenges

## Key Gameplay Mechanics

### Movement System
- **Rotation**: Snake rotates around a fixed center point when no input is pressed
- **Linear Movement**: Snake moves in straight lines when directional input is held
- **State Transitions**: Seamless switching between rotation and movement states
- **Collision**: Wall collisions and self-collisions result in death

### Tail System
- Position history tracking with configurable recording intervals
- Tail segments follow historical positions for smooth movement
- Configurable segment distance and tail length
- Visual consistency with head rotation

## Development Notes

- File logging is enabled for debugging (project.godot:24)
- Physics runs at default 60 FPS with custom delta handling
- All scripts use class_name declarations for type safety
- Consistent naming conventions with snake_case for variables
- Modular design allows easy addition of new levels and mechanics