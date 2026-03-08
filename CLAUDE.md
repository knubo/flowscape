# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

FlowMaze is an iOS puzzle/maze game written in Swift. The player navigates a maze while avoiding enemies of various types. The project targets iOS 10.3+ and uses CocoaPods for dependency management.

## Build & Run

Open `Flowmaze2.xcworkspace` (not the `.xcodeproj`) in Xcode, then build and run on a simulator or device. Always use the workspace because CocoaPods injects its framework linkage there.

```sh
open Flowmaze2.xcworkspace
```

There are no automated tests — all testing is done manually by running the app.

## Architecture

The app uses standard iOS MVC with a few notable patterns:

### Core Game Engine (`Labyrinth.swift`)
`Labyrinth` is a `UIImageView` subclass that owns the entire game loop. It renders the maze directly into its image using `UIGraphicsBeginImageContextWithOptions`, runs a timer at 50 fps (`updateTimer()` every 0.02s), and tracks game state via the `GameMode` enum (`PLAYING`, `SIMULATE`). The board is a `[[Bool]]` 2D array. Touch input is handled directly in the view.

### Enemy System
All enemies inherit from `EnemyBasis` and implement a `tick()` method called each game loop iteration. Enemies are created via factory methods on `LevelInfo` (e.g. `createSnake()`, `createFill()`). Types: `EnemySnake`, `EnemyFlow`, `EnemyBurn`, `EnemyFill`, `EnemyLaser`, `NiceSnake`.

### Persistence
`HighScores.sharedInstance` (singleton) persists per-level data — best times, full move histories, and checksums — to `UserDefaults` using the shared app group `group.flowmaze.knubo.no`. This group is also accessible from the `FlowMazeImport` share extension.

### Replay / Sharing
Completed levels can be exported as QR codes (generated via Core Image in `qr_code/`) or shared via the `FlowMazeImport` share extension. The `ImportViewController` reads saved score replays and plays them back using `GameMode.SIMULATE`.

### Navigation
Storyboard-based (`Main.storyboard`). Top-level flow: `MenuViewController` → `GameViewController` (embeds `Labyrinth`) → `HighScoreViewController` / `HighScoreDetailsViewController`.

## Key Files

| File | Role |
|------|------|
| `Labyrinth.swift` | Game loop, rendering, input — the heart of the game |
| `LevelInfo.swift` | Level definitions and enemy factory |
| `EnemyBasis.swift` | Base class for all enemies |
| `HighScores.swift` | Score persistence and replay data |
| `IAPHelper.swift` | StoreKit in-app purchase wrapper (currently unused/vestigial) |
| `web/index.html` | In-app help page displayed via `WKWebView` |
