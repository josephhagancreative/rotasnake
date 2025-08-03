# Level Editor Integration Plan

## Goal
Transform the current dynamically-generated level system into an editor-visible, visually configurable system while maintaining existing gameplay functionality.

## Phase 1: Create Editor Tool Components

### 1.1 Create LevelWall Tool Script
**File**: `LevelWall.gd`
- [ ] Create `@tool` script extending Node2D
- [ ] Add `@export var start_point: Vector2` and `@export var end_point: Vector2`
- [ ] Implement `_draw()` method to show wall line in editor (red line, 10px width)
- [ ] Add visual handles at start/end points for editor manipulation
- [ ] Include collision layer configuration (`collision_layer = 4`)
- [ ] Auto-generate StaticBody2D + CollisionShape2D when game runs

### 1.2 Create LevelWall Scene
**File**: `LevelWall.tscn`
- [ ] Root Node2D with LevelWall.gd script
- [ ] Child StaticBody2D for runtime collision
- [ ] Child CollisionShape2D with SegmentShape2D
- [ ] Set collision layer to 4 (walls)

### 1.3 Create MovingObstaclePlacement Tool Script
**File**: `MovingObstaclePlacement.gd`
- [ ] Create `@tool` script extending Node2D
- [ ] Export properties:
  - `@export var obstacle_type: String = "horizontal"` (dropdown)
  - `@export var speed: float = 100.0`
  - `@export var distance: float = 200.0`
  - `@export var start_position: Vector2`
- [ ] Implement `_draw()` method to visualize:
  - Obstacle start position (colored circle)
  - Movement path preview (different colors per pattern)
  - Direction indicators/arrows
- [ ] Add path calculation for each movement type
- [ ] Runtime instantiation of actual MovingObstacle

### 1.4 Create StaticObstacle Tool Script
**File**: `StaticObstacle.gd`
- [ ] Create `@tool` script extending StaticBody2D
- [ ] Add visual representation (colored rectangle/circle)
- [ ] Include collision layer configuration (`collision_layer = 4`)
- [ ] Editor-visible size and shape controls

### 1.5 Create GoalPlacement Tool Script
**File**: `GoalPlacement.gd`
- [ ] Create `@tool` script extending Node2D
- [ ] Add visual goal indicator for editor
- [ ] Export position property
- [ ] Runtime instantiation of actual Goal scene

## Phase 2: Update BaseLevel System

### 2.1 Modify BaseLevel.gd
- [ ] Remove `create_level_geometry()` abstract method
- [ ] Add `setup_editor_walls()` method to find and process LevelWall nodes
- [ ] Add `setup_editor_obstacles()` method for MovingObstaclePlacement nodes
- [ ] Add `setup_editor_goal()` method for GoalPlacement nodes
- [ ] Update `_ready()` to call new setup methods instead of create methods
- [ ] Maintain backward compatibility for existing levels

### 2.2 Create Level Conversion Utilities
**File**: `LevelConverter.gd` (temporary utility)
- [ ] Static methods to convert existing level data
- [ ] `convert_walls_to_nodes()` - parse wall arrays into LevelWall nodes
- [ ] `convert_obstacles_to_placements()` - convert obstacle code to placement nodes
- [ ] Helper for bulk conversion of existing levels

## Phase 3: Update Individual Levels

### 3.1 Convert Level1.tscn
- [ ] Open Level1.tscn in editor
- [ ] Add LevelWall nodes for each wall segment:
  - Outer boundary walls (4 walls)
  - Inner maze walls (convert from existing wall_segments array)
- [ ] Position walls using editor tools
- [ ] Remove Level1.gd `create_level_geometry()` override
- [ ] Test level functionality

### 3.2 Convert Level2.tscn
- [ ] Add LevelWall nodes for corridor maze
- [ ] Convert walls from current array-based system
- [ ] Remove geometry creation code from Level2.gd

### 3.3 Convert Level3.tscn
- [ ] Add LevelWall nodes for geometry
- [ ] Add MovingObstaclePlacement nodes:
  - Horizontal moving obstacle at (400, 300)
  - Vertical moving obstacle at (600, 150)
- [ ] Configure obstacle patterns and speeds
- [ ] Remove both geometry and obstacle creation code

### 3.4 Convert Remaining Levels (Level4.tscn, Level5.tscn)
- [ ] Apply same conversion process
- [ ] Special attention to Level5's complex obstacle patterns
- [ ] Maintain all current gameplay mechanics

## Phase 4: Enhanced Editor Features

### 4.1 Path Visualization Improvements
- [ ] Add curved path preview for circular obstacles
- [ ] Show timing indicators along paths
- [ ] Add collision radius visualization for obstacles
- [ ] Color-code different obstacle types

### 4.2 Level Validation Tools
- [ ] Add validation script to check:
  - Snake can reach goal from spawn point
  - No impossible obstacle configurations
  - Proper collision layer assignments
- [ ] Editor warnings for common issues

### 4.3 Level Design Helpers
- [ ] Snap-to-grid functionality for walls
- [ ] Wall connection helpers (auto-snap endpoints)
- [ ] Copy/paste obstacle configurations
- [ ] Undo/redo support for level editing

## Phase 5: Testing and Polish

### 5.1 Functionality Testing
- [ ] Verify all levels play identically to current version
- [ ] Test collision detection works correctly
- [ ] Validate obstacle movement patterns
- [ ] Check goal detection and level progression

### 5.2 Editor Experience Testing
- [ ] Test wall placement and modification
- [ ] Verify obstacle path visualization accuracy
- [ ] Ensure all exported properties work in inspector
- [ ] Test level reload/scene switching

### 5.3 Performance Validation
- [ ] Compare runtime performance to current system
- [ ] Check editor performance with complex levels
- [ ] Optimize drawing calls in editor tools

## Phase 6: Documentation and Cleanup

### 6.1 Update Project Documentation
- [ ] Update CLAUDE.md with new level editing workflow
- [ ] Document new node types and their properties
- [ ] Add level design guidelines

### 6.2 Code Cleanup
- [ ] Remove unused dynamic generation code
- [ ] Clean up temporary conversion utilities
- [ ] Add proper code comments to new editor tools
- [ ] Ensure consistent naming conventions

## Implementation Priority
1. **Phase 1** - Create the fundamental editor tools
2. **Phase 2** - Update BaseLevel to work with new system
3. **Phase 3** - Convert one level at a time (start with Level1)
4. **Phase 4** - Add enhanced features after basic system works
5. **Phase 5** - Comprehensive testing
6. **Phase 6** - Documentation and cleanup

## Success Criteria
- All existing levels function identically to current gameplay
- Level geometry is fully visible and editable in Godot editor
- Moving obstacles show clear path previews in editor
- New levels can be created entirely through editor tools
- No regression in game performance or functionality