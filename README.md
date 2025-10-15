# The Incredible Machine: A CS50 Final Project

#### Video Demo: <URL HERE>
#### Description: *A Love2D reimagining of the classic puzzle game, The Incredible Machine.*

---

## 1. Introduction

"The Incredible Machine" is a 2D physics-based puzzle game developed as a final project for Harvard's CS50 course. It is a modern homage to the classic 1990s game of the same name, built from the ground up using the Love2D game engine. The project's primary goal is to recreate the original's addictive and creative gameplay while introducing a powerful new feature: the ability to script game components with Lua.

In this sandbox environment, players are presented with a simple objective, such as "pop a balloon" or "turn on a light." To achieve this, they must build a Rube Goldberg-style contraption from a limited set of parts. The joy of the game comes from discovering clever and often absurd solutions through experimentation. By combining physics with logic, players can create chain reactions that are both functional and entertaining. This project not only serves as a demonstration of software engineering principles but also as a celebration of creativity and problem-solving.

---

## 2. Core Gameplay Mechanics

The gameplay is divided into two main modes, which the player can switch between at any time:

| Mode          | Description                                                                                                                                                             |
|---------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 🧠 **Build Mode** | In this mode, the simulation is paused. Players can drag and drop parts from a toolbox onto the level canvas. They can rotate, position, and configure each part's properties. This is the primary creation phase. |
| ⚙️ **Run Mode**   | This mode unpauses the simulation and brings the contraption to life. The physics engine takes over, and the player can watch their creation in action. This is where the success or failure of the machine is determined. |

Beyond these modes, the game includes several key features:

*   **Save/Load System:** Players can save their contraptions to a file (as a Lua table or JSON object) and load them back into the game. This allows for sharing creations and saving progress on complex puzzles.
*   **Puzzle-Based Levels:** The game is structured around a series of puzzles. Each puzzle has a clear goal and provides a limited inventory of parts, challenging the player to find a solution within the given constraints.
*   **Scriptable Components:** The most significant addition to the classic formula is the ability to script components. Each part can have a small Lua script attached to it, allowing for complex logical behaviors. For example, a button could be scripted to activate a fan only if a specific other condition is met.

---

## 3. Project Structure

The project is organized into a modular and scalable directory structure. This separation of concerns is crucial for maintaining a clean and understandable codebase.

```
the_incredible_machine/
├── main.lua
├── conf.lua
├── assets/
│   ├── sprites/
│   ├── sounds/
│   └── fonts/
├── src/
│   ├── core/
│   │   ├── physics.lua
│   │   ├── input.lua
│   │   ├── save.lua
│   └── entities/
│       ├── base.lua
│       ├── ball.lua
│       ├── fan.lua
│       ├── button.lua
│       ├── balloon.lua
│       └── joint.lua
├── levels/
│   ├── tutorial1.lua
│   ├── windpower.lua
│   └── chainreaction.lua
└── README.md
```

#### File Breakdown:

*   `main.lua`: This is the heart of the game and the main entry point for Love2D. It contains the primary game loop, including `love.load()`, `love.update(dt)`, and `love.draw()`. It is responsible for loading all other modules, managing the game state (e.g., switching between Build and Run modes), and orchestrating the interactions between different systems.

*   `conf.lua`: A special Love2D file used to configure the application's settings before any other modules are loaded. This includes setting the window title, dimensions, and other global parameters.

*   `assets/`: This directory is a container for all external media used by the game.
    *   `sprites/`: Contains all image files for the game's entities and UI elements.
    *   `sounds/`: Holds all sound effects and music tracks.
    *   `fonts/`: Stores any custom font files used for rendering text.

*   `src/`: This is where the core game logic resides.
    *   `core/`: This module contains the fundamental systems that drive the game.
        *   `physics.lua`: Manages the Box2D physics world, including gravity, collisions, and other physical properties.
        *   `input.lua`: Handles all player input, such as mouse clicks for dragging parts and keyboard shortcuts.
        *   `save.lua`: Implements the logic for saving and loading game states and contraptions.
    *   `entities/`: This module defines all the interactive objects in the game.
        *   `base.lua`: A base class from which all other entities inherit. It contains common properties and methods, such as position, rotation, and drawing logic. This promotes code reuse and a consistent object interface.
        *   `ball.lua`, `fan.lua`, etc.: Each of these files defines a specific type of entity, with its own unique properties and behaviors.

*   `levels/`: This directory contains the data for each puzzle. Each level is a Lua script that returns a table defining the goal, the available parts, and the initial layout of the level. This data-driven approach makes it easy to create new puzzles without modifying the core game logic.

*   `README.md`: This file, providing a comprehensive overview of the project.

---

## 4. Design Decisions

Several key design decisions were made during the planning of this project:

*   **Choice of Engine (Love2D):** Love2D was chosen for its simplicity, power, and the fact that it uses Lua. Since the goal was to create a game with scriptable components, using an engine that is itself based on Lua was a natural fit. This allows for a seamless integration between the game's core logic and the user-defined scripts. Love2D's built-in Box2D physics engine was also a major selling point, as it provides the core functionality for the game's simulation.

*   **Entity-Component System (ECS) vs. Inheritance:** While an ECS architecture is a popular choice for modern game development, I opted for a simpler object-oriented inheritance model for this project. Given the relatively small number of entity types and the clear "is-a" relationship between them (e.g., a ball "is a" type of entity), inheritance offered a more straightforward and quicker implementation path. The `base.lua` class serves as the foundation for all entities, providing a clean and understandable structure.

*   **Data-Driven Levels:** Instead of hard-coding level data within the game's source code, I chose to store levels as separate Lua files. This decouples the level design from the game logic, allowing for rapid iteration on new puzzles. A level designer (or even a player) could create new levels without ever touching the core `src/` files.

*   **Scripting Implementation:** The decision to allow user-scriptable components is the project's most ambitious feature. The primary challenge is to provide a powerful scripting environment while sandboxing it to prevent malicious or game-breaking code. The design involves giving each scripted entity its own Lua environment and a limited API to interact with the game world. This was deemed a more engaging and flexible approach than a purely visual, node-based logic system.

---

## 5. How to Play

To run "The Incredible Machine," you will need to have Love2D installed on your system. You can download it from the official website: [love2d.org](https://love2d.org/).

Once Love2D is installed, you can run the game by either:
1.  Dragging the project folder onto the Love2D application executable.
2.  Navigating to the project's root directory in your terminal and running the command: `love .`

---

## 6. Future Work

While the current version of the game implements the core features, there are many possibilities for future expansion:

*   **More Parts:** The game could be expanded with a much wider variety of parts, including electrical components, lasers, mirrors, and more complex logical gates.
*   **Level Editor:** A built-in, user-friendly level editor would allow players to create and share their own puzzles with the community.
*   **Online Sharing:** An online platform for sharing saved contraptions and custom levels would greatly enhance the social and community aspects of the game.
*   **Improved Scripting API:** The scripting API could be expanded to provide even more control over the game world, allowing for truly complex and emergent behaviors.

This project has been a rewarding journey into the world of game development, physics simulation, and API design. It stands as a testament to the power of simple mechanics combined with creative freedom.