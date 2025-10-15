# The Incredible Machine

#### Video Demo: https://youtu.be/KuPl5pMlOaY

#### Description: A small 2D physics sandbox built with LÖVE (Love2D) as a CS50 final project. Place parts, toggle the simulation, and build contraptions to achieve an objective.

Requirements: LÖVE 11.3 or newer - [https://love2d.org](https://love2d.org)

## Project structure

The Incredible Machine is a compact 2D physics sandbox implemented with LÖVE (Love2D) and submitted as a final project for Harvard's CS50. The goal of the project is to provide a small, deterministic environment in which students (and graders) can build simple Rube-Goldberg-style contraptions from a limited set of parts and verify correctness quickly.

## Controls

- SPACE — Toggle Run / Edit mode
- 1 — Select Energy Ball (place with left-click)
- 2 — Select Fan
- 3 — Select Balloon (goal)
- 4 — Select Scissors (rotatable; scissors pop balloons on contact)
- 5 — Select Ramp (click-drag to place)
- Drag — Move objects in Edit mode
- R — Rotate selected object (in Edit mode)
- ESC — Return to main menu

Objective used for the submission: "Pop the balloon to win." The game listens for precise physics contacts (scissors touching balloon) to register the pop event.

## Files to inspect (what I wrote and why)

I focused my work on a small number of files so you can find the logic quickly:

- `main.lua` — Bootstraps the game, loads fonts and assets, and switches to the `playing` state by default.
- `conf.lua` — (optional) Love2D configuration (window defaults).
- `src/core/physics.lua` — Central physics wrapper: creates the Box2D world and implements collision callbacks. Critical behaviors implemented here:
 	- Fan activation: fans track contact count with the energy ball (beginContact/endContact) and apply force only while in contact.
	- Balloon popping: scissors↔balloon contacts set a `popped` flag on the balloon which is used to trigger the win condition.
- `src/states/playing.lua` — The Play/Edit state. Responsibilities:
	- Editor controls: placement (click), dragging, rotation (`R`) and ramp click-drag placement.
	- Game loop: toggles between edit and run modes, invokes `physics.world:update(dt)` in run mode, and checks the win condition.
	- HUD and small UI helpers (selection icons, cursor ghost preview, objective placement and theming).
- `src/entities/` — All entity definitions:
	- `base.lua` — simple base class for shared properties.
	- `ball.lua` — the energy ball (dynamic body).
	- `fan.lua` — fan entity (static body) with on/off sprites and force application computed from body angle.
	- `balloon.lua` — balloon entity with pop animation frames; `popped` is set via physics contact.
	- `scissors.lua` — rotatable scissors that trigger balloon popping on contact.
	- `ramp.lua` — static, rotated rectangle used to change ball trajectories.

Assets (sprites and fonts) are in `assets/`.

## Design choices and rationale

- Determinism over flash: Because consistent behavior is more important than fancy visuals, gameplay events are driven by precise Box2D contact callbacks rather than timing or visual heuristics. This reduces flakiness across machines and runs, so graders can reproduce outcomes reliably. Physics parameters are kept explicit and well-commented so reviewers can trace interactions and reproduce specific scenarios.

- Small codebase and readable structure: The project uses a tiny `base` entity that provides lifecycle hooks (create/update/draw/destroy) and shared fields (body, fixtures, userData). Each concrete entity lives in its own small file and only implements the behavior it needs. That makes it straightforward for a grader to open `src/entities/` and understand object behavior quickly without tracing through a large monolithic file.

- Data-driven levels: Level data are plain Lua tables under `levels/` describing entity type, position, rotation and minimal properties. Because levels are data, graders can add or tweak scenarios without editing engine code. The default blank playfield further simplifies reproducing minimal test cases and verifying correctness.

## Future work (optional)

If allowed more time I would:

- Add a persistent save/load for contraptions.
- Add a small settings menu (vignette toggle, background color, HUD visibility).
- Add extra more parts (timers, buttons, electrical-like logic gates) and a small in-game level editor with sharing.
