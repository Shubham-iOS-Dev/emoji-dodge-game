
# Emoji Dodge 👾

A fast-paced, arcade-style mobile game built with SwiftUI. Players must control a character at the bottom of the screen to dodge falling obstacles and survive for 60 seconds to win.

## Project Overview
Emoji Dodge is designed to test reflexes through a simple yet addictive game loop. As the player's score increases, the speed of falling emojis scales, making survival increasingly difficult over time.

## Technology Stack
* **Language:** Swift 6.0
* **Framework:** SwiftUI
* **Architecture:** State-driven Declarative UI
* **Tools:** Xcode 17+, Timer API, Combine (for game loop)

## Development Approach
The game follows a functional reactive approach:
1.  **Game Loop:** A `Timer` publishes updates every 0.02 seconds to drive the physics engine.
2.  **State Management:** An `enum` (GameState) manages transitions between the Home Screen, Gameplay, Win, and Game Over states.
3.  **Collision Logic:** Mathematical distance checks are used to detect overlaps between the player's coordinate and falling emoji coordinates.
4.  **UI/UX:** Utilizes `GeometryReader` to ensure the game is responsive and playable across all iPhone screen sizes.

## Steps to Run the Project
1.  Clone or download this repository.
2.  Open the project folder and double-click the `.xcodeproj` file to open it in **Xcode**.
3.  Select an iPhone Simulator (e.g., iPhone 15 or 16).
4.  Press `Cmd + R` to Build and Run.
5.  Use your mouse (simulator) or finger (device) to drag the player left and right.
