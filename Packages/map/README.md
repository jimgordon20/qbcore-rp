# Minimap and Bigmap Package

## Overview

This package provides a functional **minimap** and **bigmap** system, allowing players to view their surroundings, see other players, add and remove blips, toggle map shape, and teleport to blips.

## Features

- **Minimap:** Displays player position and blips with a configurable shape (`circle` or `square`).
- **Bigmap:** Full-screen map with interactive blips, waypoints, and teleportation.
- **Blip Management:** Add and remove blips dynamically on both minimap and bigmap.
- **Waypoint System:** Double-click to add a waypoint, right-click to remove it.
- **Player Tracking:** Updates player position and heading on both maps.
- **Configurable UI:** Adjust minimap position, shape, and blip visibility.

## Installation

- Replace the existing map.png file with your own map image.
- Open UI/Bigmap/index.html in a browser.
- Click on three distinct points on the map; their coordinates will appear in the browser's developer console (The more distant the coordinates, the more accurate the map will be).
- Enter the game and find the same three points in the world, noting their in-game coordinates.
- Update KnownImageCoords with the browser coordinates and KnownGameCoords with the in-game coordinates in shared/Index.lua.

## Configuration

The `Config` table in `shared/Index.lua` allows you to customize various aspects of the minimap and bigmap. Below are the key configurable options:

- `ScreenPosition`: Defines where the minimap appears on the screen.
  - `0` = top-left
  - `1` = top-right
  - `2` = bottom-left
  - `3` = bottom-right
- `Shape`: Determines the shape of the minimap.
  - Options: `"circle"` or `"square"`
- `MaxMinimapBlipsCount`: Limits the number of blips that can be displayed on the minimap at the same time.
- `KnownGameCoords`: A list of three game world coordinates used for coordinate conversion between the map image and the in-game world.
- `KnownImageCoords`: The corresponding coordinates on the `map.png` image that match the game world coordinates from `KnownGameCoords`. These values are essential for proper blip placement.
- `MapBlips`: A predefined list of locations that will appear as blips on the minimap and bigmap. Each blip entry has the following structure:

```lua
MapBlips = {
    { name = "Sushi Shop", coords = { x = 1200, y = 3400 }, imgUrl = "./media/map-icons/Food-icon.svg", group = "Food" },
    { name = "Gas Station", coords = { x = -5400, y = 12500 }, imgUrl = "./media/map-icons/Gas-station-icon.svg", group = "Business" }
}
```

Each blip entry consists of:
- `name`: Display name of the blip.
- `coords`: The in-game coordinates where the blip should appear.
- `imgUrl`: The file path to the icon image used for the blip.
- `group`: A category that can be used for filtering blips on the map.

```lua
Config = {
    ScreenPosition = 2, -- 0 = top-left, 1 = top-right, 2 = bottom-left, 3 = bottom-right
    Shape = "square",   -- "circle" or "square"
    MaxMinimapBlipsCount = 30
}
```

## Usage

### Minimap

- **Automatically updates** player position.
- Use `/ToggleMinimapShape` command to switch between `circle` and `square`.
- Displays **limited** nearby blips.

### Bigmap

- Press `M` to toggle visibility.
- **Double-click** to add a waypoint.
- **Right-click** to remove a waypoint.
- **Arrow keys** navigate blips.
- Press `Enter` to **teleport** to a selected blip.

### Blip Management

```lua
-- Add a blip (returns id)
events.CallRemote("Map:AddBlip", blipData)

-- Remove a blip
events.CallRemote("Map:RemoveBlip", blipId)
```
