# My Brickbook

A small iOS app to collect “bricks”—family characters and home items—and unlock short stories. A tiny record of your home moments.

## Features

- **Collection** — Collect Home bricks (e.g. kettle, toaster, lemon tree) and Family characters (Maya, Leo, Finn, Laura, Olive, Joy, Woofa, Whiskers).
- **Stories** — Unlock little narrative moments when you add certain cards; some stories require owning other cards first.
- **Logbook** — View unlocked stories, search and filter by character or card.
- **Design** — Cream and sage green theme, minimal UI, SwiftUI.

## Requirements

- Xcode 15+
- iOS 17+

## Getting Started

1. Clone the repo:
   ```bash
   git clone https://github.com/Yunnqii/My-Brickbook.git
   cd My-Brickbook
   ```
2. Open `My Brickbook/My Brickbook.xcodeproj` in Xcode.
3. Select a simulator or device and run (⌘R).

## Project Structure

- `My Brickbook/` — App target: SwiftUI views, `AppState`, `DataLoader`, theme, assets.
- `collectibles.json` / `stories.json` — Card and story data.
- `scripts/make_app_icon.py` — Generates the app icon (Pillow).

## Storylines & Characters

See [APP故事线与人物介绍.md](APP故事线与人物介绍.md) for character intros and story structure (in Chinese).

## License

Private / personal project.
