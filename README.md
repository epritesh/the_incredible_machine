# The Incredible Machine

A small 2D physics sandbox built with LÖVE (Love2D) as a CS50 final project. Place parts, toggle the simulation, and build Rube-Goldberg-style contraptions.

This repository intentionally keeps the experience minimal: no sounds or particle effects are included so the game is easy to test and grade.

## Run

Requirements:
- LÖVE 11.3 or later (https://love2d.org)

From the project root run:

```bash
love .
```

On Linux you can also install love via your package manager (for example: `sudo apt install love`), then run the command above from this directory.

## Controls

- SPACE — Toggle Run / Edit mode
- 1 — Select Energy Ball (place with left-click)
- 2 — Select Fan
- 3 — Select Balloon
- 4 — Select Scissors
- 5 — Select Ramp (click-drag to place)
- Drag — Move placed objects in Edit mode
- R — Rotate selected object (in Edit mode)
- ESC — Return to main menu

In Run mode the physics simulation runs and objects interact. The simple objective is "POP THE BALLOON TO WIN!" when the goal target is a balloon.

## Project structure (short)

- `main.lua` — Bootstraps the game and states
- `src/` — Game code: entities, physics, states
- `assets/` — Sprites and fonts

## Notes for grading / running

- The game starts with a blank playfield. Use Edit mode to place parts and then press SPACE to run the simulation.
- The game intentionally avoids sounds/particles.
- If you see visual overlap of HUD and objective text, resize the window or report the resolution and I'll adjust the HUD padding.

## Next improvements (todo)

- Replace proximity-based balloon popping with precise contact-based popping.
# The Incredible Machine

The Incredible Machine is a small 2D physics sandbox built with LÖVE (Love2D) as a final project for Harvard's CS50. The project recreates the spirit of Rube-Goldberg puzzles: place a few simple parts and watch a chain reaction unfold. The version submitted for CS50 is intentionally minimal and focused on correctness, clarity, and reproducibility so it is easy to grade.

This README explains how to run the game, how the project is organized, which files were authored for this submission, and why certain design decisions were made. If you are grading or testing the project, the "How to test" section near the end gives a reproducible, short playtest checklist.

## Quick run instructions

Requirements
- LÖVE 11.3 or newer (https://love2d.org)

From the project root run:

```bash
love .
```

On Linux you can also install LÖVE via your package manager (for example: `sudo apt install love`) and then run the command above from this directory.

The game starts on a blank playfield. Use Edit mode to place parts and then press SPACE to switch to Run mode and simulate.

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

The default objective used for the CS50 submission is simple: "Pop the balloon to win." That objective is satisfied when the balloon's physics body receives a pop event (scissors contact) — the game uses precise physics contacts rather than distance heuristics, which reduces false positives and makes behavior deterministic for grading.

## Files you should inspect (what I wrote and why)

Below are the most relevant files I authored or modified for the submission and a short description of each. These descriptions should make it straightforward for graders to navigate the codebase and verify behavior.

- `main.lua` — Bootstraps the game and switches to the `playing` gamestate by default. Keeps initialization minimal so the grader can immediately run the editable playfield.
- `conf.lua` — (optional) Love2D configuration used to set window defaults where applicable.
- `src/core/physics.lua` — Wraps the Love2D/Box2D world and contains collision callbacks. Important changes: fans now activate when the energy ball is in contact (beginContact/endContact tracks contact counts), and scissors↔balloon contacts trigger the balloon pop.
- `src/states/playing.lua` — The in-game editor/run state. Handles placing parts, seeding the blank scene (one of each part for playtesting), the objective logic (balloon pop → win), and HUD placement. This file also contains the simple editor controls used for the submission.
- `src/entities/base.lua` — A small base class shared by entities: position, rotation, and helper methods.
- `src/entities/ball.lua` — The energy ball. It is the only dynamic rolling object spawned by the editor by default.
- `src/entities/fan.lua` — A fan entity. Fans apply continuous force when active; direction is computed from their physics body angle so rotation and behavior match visually.
- `src/entities/balloon.lua` — The balloon goal. Popping is handled by the physics contact system and toggles the win state.
- `src/entities/scissors.lua` — A new rotatable scissors entity; collisions between scissors and a balloon cause the balloon to pop.
- `src/entities/ramp.lua` — A simple static ramp. Ramps allow the ball to roll and change trajectory.

Assets (sprites and fonts) are located in `assets/`. The submission intentionally omits sounds and particle effects to keep the project deterministic and easy to grade.

## Design choices and rationale

1) Simplicity and determinism: For a grading environment, deterministic and testable behavior is more valuable than visual polish. As a result, the game avoids sound and particle effects, seeds the playfield with a simple starting set for quick testing, and uses physics contacts for critical events (fan activation and balloon popping) so behavior is consistent across runs.

2) Inheritance-like entity model: I used a small, pragmatic base class pattern rather than a full ECS. This keeps the code compact and readable given the modest number of entity types in the submission. The project is structured so it would be straightforward to refactor to ECS later if the codebase grows.

3) Physics-driven interactions: The game uses LÖVE's Box2D bindings for all interactions. Collisions drive gameplay events (fans activating, balloons popping) which makes the simulation feel natural and minimizes artificial rule checks in update loops.

4) Edit vs Run modes: The editor is intentionally simple: place, rotate, and drag. This is enough to construct meaningful machines while keeping the code and UI minimal for grading.

## How to test (short reproducible checklist)

1. Start the game: `love .` — you should see the main menu and can click "Start" to enter the blank playfield.
2. Press `1` and place an Energy Ball near the top-left, press `2` and place a Fan aimed right, press `3` to place a Balloon somewhere reachable, press `4` to add Scissors and rotate them so the sharp edge faces the balloon path.
3. Press SPACE to run — if the fan pushes the energy ball into the scissors or the scissors intersect the balloon, the balloon should pop and the objective message appears.

This README was written to help a grader quickly verify the submission and to explain the major engineering trade-offs. If you want extra documentation (annotated code walkthrough, demo GIF, or a short test level demonstrating a solved contraption), tell me which one and I will add it.

---

Thank you for reviewing this submission. Good luck grading and happy tinkering!