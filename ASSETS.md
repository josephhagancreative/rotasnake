# Rotasnake - Pixel Art Asset Specifications

This document outlines all the custom pixel art assets needed for the Rotasnake game, with recommended sizes and specifications.

## Game Scale Analysis

- **Current Resolution**: 1024x600 (will be changed to 320x640 as requested)
- **Current Collision Sizes**: Snake head 12px radius, tail segments 10px radius
- **Recommended Sprite Size**: 32x32 pixels (provides good detail while maintaining retro aesthetic)
- **Alternative Size**: 16x16 pixels (more classic retro, but less detail)

## Core Game Assets

### Snake Components

#### 1. Snake Head
- **Size**: 32x32 pixels
- **Format**: PNG with transparency
- **Description**: The main snake head that shows facing direction
- **Design Notes**: 
  - Should clearly indicate forward direction (pointed or arrow-like)
  - Bright/contrasting colors for visibility
  - Consider adding small details like eyes or patterns
  - Will rotate to match movement direction

#### 2. Snake Body Segment
- **Size**: 32x32 pixels  
- **Format**: PNG with transparency
- **Description**: Regular body segments that form the snake's tail
- **Design Notes**:
  - Slightly smaller visual appearance than head
  - Should connect well when placed in sequence
  - Complement the head's color scheme
  - Consider subtle pattern or texture

#### 3. Snake Tail End
- **Size**: 32x32 pixels
- **Format**: PNG with transparency  
- **Description**: Final segment of the snake's tail
- **Design Notes**:
  - Tapered or pointed end to show tail termination
  - Same color scheme as body segments
  - Should feel like a natural conclusion to the snake

### Environment Assets

#### 4. Wall Tile
- **Size**: 32x32 pixels
- **Format**: PNG
- **Description**: Static wall obstacles that form level boundaries
- **Design Notes**:
  - Solid, impassable appearance
  - Should tile seamlessly for continuous walls
  - Consider stone, metal, or futuristic theme
  - High contrast with background for clarity

#### 5. Moving Obstacle
- **Size**: 32x32 pixels
- **Format**: PNG with transparency
- **Description**: Dynamic hazards that move in patterns
- **Design Notes**:
  - Dangerous/threatening appearance
  - Distinct from walls (different color/style)
  - Consider spikes, saws, energy orbs, or spinning blades
  - Should be visually animated-friendly (current code spins them)

#### 6. Goal Target
- **Size**: 32x32 pixels
- **Format**: PNG with transparency
- **Description**: Level completion target
- **Design Notes**:
  - Attractive, collectible appearance
  - Bright colors to draw attention
  - Consider gems, fruits, power cores, or portals
  - Should look rewarding to collect

### Background Elements

#### 7. Background Tile
- **Size**: 32x32 pixels
- **Format**: PNG
- **Description**: Repeating background pattern for levels
- **Design Notes**:
  - Subtle pattern that doesn't distract from gameplay
  - Low contrast to keep focus on game objects
  - Should tile seamlessly in all directions
  - Consider circuit patterns, space, grid, or abstract designs

#### 8. Background Tile Variant (Optional)
- **Size**: 32x32 pixels
- **Format**: PNG
- **Description**: Alternative background for visual variety
- **Design Notes**:
  - Similar style to main background but with variation
  - Can be used for different level themes
  - Maintains same low contrast principle

## UI Elements (Optional Enhancements)

#### 9. Level Complete Icon
- **Size**: 64x64 pixels
- **Format**: PNG with transparency
- **Description**: Visual indicator for level completion
- **Design Notes**:
  - Celebratory appearance (star, trophy, checkmark)
  - Bright, positive colors

#### 10. Death/Game Over Icon  
- **Size**: 64x64 pixels
- **Format**: PNG with transparency
- **Description**: Visual indicator for death/failure
- **Design Notes**:
  - Clear failure indication without being too harsh
  - Could be skull, X mark, or explosion effect

## Technical Specifications

### File Formats
- **Primary**: PNG with transparency where needed
- **Backup**: PNG without transparency for solid tiles
- **Compression**: Optimize for web/game use

### Color Palette Recommendations
- **Snake**: Bright green (#00FF00) with darker green accents (#00AA00)
- **Walls**: Dark gray/blue (#2C3E50) or metallic colors
- **Obstacles**: Warning red (#E74C3C) or electric blue (#3498DB)
- **Goal**: Gold (#F1C40F) or bright cyan (#1ABC9C)
- **Background**: Muted colors (#34495E, #95A5A6) with low saturation

### Scale Considerations
- All sprites designed for 32x32 will work well at the new 320x640 resolution
- This gives a 10x20 grid, perfect for level design
- Sprites will appear crisp and detailed at this scale
- Consider pixel-perfect alignment (no sub-pixel positioning)

## Asset Priority

### High Priority (Core Gameplay)
1. Snake Head
2. Snake Body Segment  
3. Wall Tile
4. Goal Target

### Medium Priority (Enhanced Experience)
5. Snake Tail End
6. Moving Obstacle
7. Background Tile

### Low Priority (Polish)
8. Background Tile Variant
9. Level Complete Icon
10. Death/Game Over Icon

## Implementation Notes

- All assets should be designed at exactly 32x32 pixels for consistency
- Ensure pixel-perfect design (no anti-aliasing on edges)
- Test assets in-game to verify visibility and contrast
- Consider creating a cohesive art style across all assets
- Maintain readability at the target resolution

## File Naming Convention

- `snake_head.png`
- `snake_body.png`
- `snake_tail.png`
- `wall.png`
- `obstacle.png`
- `goal.png`
- `bg_tile.png`
- `bg_tile_alt.png`
- `icon_complete.png`
- `icon_death.png`