# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is "Rotasnake" - a Godot 4.4 snake game with unique rotation-based movement mechanics. The snake can move in straight lines or rotate in place, creating a distinctive gameplay experience compared to traditional grid-based snake games. The game features multiple difficulty modes, 7+ levels, and sophisticated collision detection.

## Project Structure

### Root Directory
```
/rotasnake/
├── project.godot              # Godot project configuration
├── CLAUDE.md                  # This documentation file
├── icon.svg                   # Project icon
│
├── GameManager.gd             # Singleton for game state management
├── MainMenu.gd/.tscn         # Main menu scene and logic
├── Snake.gd/.tscn            # Main snake character
├── BaseLevel.gd/.tscn        # Base class for all levels
├── TestLevel.gd/.tscn        # Development/testing level
│
├── Core Game Objects:
├── tail_segment.gd            # Individual tail segment logic
├── TailSegment.tscn          # Tail segment scene
├── Goal.gd/.tscn             # Level completion target
├── MovingObstacle.gd/.tscn   # Dynamic hazards
├── LevelWall.gd/.tscn        # Static level boundaries
├── SnakeStartPoint.gd/.tscn  # Configurable snake spawn points
├── MovingObstaclePlacement.gd/.tscn  # Editor tool for obstacle placement
│
└── levels/                   # Level scenes
    ├── Level1.gd/.tscn      # Tutorial level
    ├── Level2.gd/.tscn      # Rotation introduction
    ├── Level3.gd/.tscn      # Moving obstacles
    ├── Level4.gd/.tscn      # Complex navigation
    ├── Level5.gd/.tscn      # Advanced challenges
    ├── Level6.gd/.tscn      # Expert difficulty
    └── Level7.gd/.tscn      # Master level
```

## Development Commands

### Running the Project
- Open the project in Godot Editor by loading `project.godot`
- Press F5 or click "Play" to run the game
- Press F6 to run the current scene

### Project Configuration
- Main scene: `MainMenu.tscn` (project.godot:14)
- Godot version: 4.4 with GL Compatibility renderer
- Display: 1024x600 viewport with canvas_items stretch mode
- Default gravity disabled (2D physics)
- File logging enabled for debugging

## Core Architecture

### Game Management (GameManager.gd)
Singleton autoload managing the entire game flow:
- **Level Progression**: Tracks current level (1-10) and completion state
- **Difficulty Modes**: Easy mode (forward movement allowed) vs Hard mode (rotation only)
- **Scene Management**: Handles level loading, transitions, and main menu
- **Game State**: Manages restart functionality and auto-advancement

### Snake System (snake.gd)
The core character controller with sophisticated movement mechanics:

#### Movement States
- `State.MOVING`: Linear movement in cardinal directions at 125px/s
- `State.ROTATING`: Circular rotation around a center point at 2.0 rad/s
- `State.TRANSITIONING`: Smooth transition between rotation directions

#### Movement Modes
- `MovementMode.CLOCKWISE`: Rotate clockwise around current center
- `MovementMode.COUNTER_CLOCKWISE`: Rotate counter-clockwise around current center
- `MovementMode.FORWARD`: Move straight in facing direction (Easy mode only)

#### Advanced Features
- **Dynamic Rotation Centers**: Calculated based on current position and facing direction
- **Smooth Transitions**: 0.1s transition when changing rotation direction
- **Position History**: 300-entry history for smooth tail following
- **Collision Immunity**: 2s immunity at spawn to prevent immediate self-collision
- **Visual Feedback**: Death animations with color changes and scaling

### Level System (BaseLevel.gd)
Abstract base class providing common level functionality:
- **Snake Spawning**: Configurable start positions and facing directions via SnakeStartPoint
- **Goal Detection**: Automatic level completion when snake reaches goal
- **Death Handling**: Visual feedback and restart prompts
- **Input Management**: Unified restart (SPACE) and quit (ESC) handling
- **Editor Integration**: Automatic processing of editor-placed obstacles

### Game Objects

#### TailSegment (tail_segment.gd)
- Physics body following snake's position history
- Smaller collision radius (10px) than head (12px)
- Collision layer 2 for self-collision detection
- Smooth rotation matching head movement

#### MovingObstacle (MovingObstacle.gd)
Dynamic hazards with multiple movement patterns:
- **Horizontal/Vertical**: Linear back-and-forth movement
- **Circular**: Smooth circular motion around start position
- **Square**: Precise square pattern with phase-based movement
- **Collision**: Layer 4 (hazards) that kills snake on contact
- **Visual**: Red coloration with spinning animation

#### Goal (Goal.gd)
- Level completion trigger on collision layer 6
- Pulsing animation for visual attraction
- Green color feedback on completion

#### LevelWall (LevelWall.gd)
- Static obstacles on collision layer 3
- Forms level boundaries and navigation challenges

#### SnakeStartPoint (SnakeStartPoint.gd)
- Editor tool for precise snake placement
- Configurable position and facing direction
- Visual indicators in editor (hidden at runtime)

#### MovingObstaclePlacement (MovingObstaclePlacement.gd)
- Editor tool for placing MovingObstacles
- Runtime spawning with configured parameters
- Automatic cleanup and group management

## Physics and Collision System

### Collision Layers (project.godot:71-76)
1. **snake_head** (Layer 1): Snake head collision detection
2. **snake_tail** (Layer 2): Tail segments for self-collision
3. **walls** (Layer 3): Static level boundaries and obstacles
4. **hazards** (Layer 4): Moving obstacles that kill the snake
5. **collectibles** (Layer 5): Items that can be picked up (future use)
6. **goal** (Layer 6): Level completion triggers

### Collision Matrix
- Snake head detects: tail (self-collision), walls, hazards, goal
- Tail segments: No collision detection (passive)
- Moving obstacles: Detect snake head only
- Walls: Block snake movement
- Goal: Detect snake head for completion

## Input System (project.godot:34-67)

### Movement Controls
- **WASD or Arrow Keys**: Primary movement input
- **Left/A**: Counter-clockwise rotation
- **Right/D**: Clockwise rotation  
- **Up/W**: Forward movement (Easy mode only)
- **Down/S**: Alternative input (mapped to down arrow)

### Menu Controls
- **SPACE/ENTER**: Restart level or advance to next
- **ESC**: Return to main menu or quit

### Input Processing
- Real-time state transitions between movement modes
- Immediate response to direction changes
- Hard mode disables forward movement input

## Gameplay Mechanics Integration

### Movement System Interaction
The three movement modes work together to create fluid gameplay:
1. **Rotation to Linear**: Tangent direction becomes movement direction
2. **Linear to Rotation**: Current position becomes point on new rotation circle
3. **Direction Changes**: Smooth transitions maintain momentum and visual continuity

### Collision Detection Chain
1. Snake head movement triggers collision checks
2. Wall collision → immediate death
3. Self-collision → death (with immunity period)
4. Hazard collision → death via area detection
5. Goal collision → level completion

### Level Progression Flow
1. **Spawn**: Snake placed at SnakeStartPoint with configured direction
2. **Movement**: Player controls via input system
3. **Obstacles**: MovingObstacles provide dynamic challenges
4. **Completion**: Goal contact triggers level completion
5. **Transition**: GameManager advances to next level

### Difficulty Scaling
- **Easy Mode**: Full movement options, forward escape routes
- **Hard Mode**: Rotation-only movement, starts in rotation state
- **Level Design**: Progressive complexity in obstacle patterns
- **Moving Obstacles**: Increasing density and pattern complexity

## Scene Architecture

### Main Menu (MainMenu.tscn)
- **Easy Mode Button**: Starts game with forward movement enabled
- **Hard Mode Button**: Starts rotation-only challenge mode
- **Quit Button**: Exits application
- **Input Handling**: ESC to quit, focus management

### Level Structure
Each level inherits from BaseLevel and adds:
- **Custom Geometry**: Unique wall layouts via TileMap
- **Obstacle Placement**: MovingObstaclePlacement nodes for dynamic hazards
- **Start Configuration**: SnakeStartPoint for precise spawn control
- **Goal Positioning**: Strategic goal placement for optimal challenge

### Asset Organization
- **Scenes**: Modular prefab system for reusable components
- **Scripts**: Class-based inheritance with clear separation of concerns
- **Autoloads**: GameManager singleton for global state
- **Groups**: "moving_obstacles" group for batch operations

## Development Notes

### Code Quality
- All scripts use `class_name` declarations for type safety
- Consistent naming conventions with snake_case
- Modular design allows easy addition of new levels and mechanics
- Comprehensive cleanup systems prevent memory leaks

### Performance
- Physics runs at 60 FPS with optimized collision detection
- Position history limited to 300 entries with 0.02s intervals
- Efficient tail following algorithm using array indexing
- Tween cleanup prevents memory accumulation

### Debugging
- File logging enabled (project.godot:24)
- Visual feedback for all game states
- Clear separation between editor tools and runtime components
- Collision layer visualization in editor

### Extensibility
- New levels easily added via BaseLevel inheritance
- New obstacle patterns via MovingObstacle configuration
- Additional movement modes can be added to the enum system
- Physics layers reserved for future features (collectibles)