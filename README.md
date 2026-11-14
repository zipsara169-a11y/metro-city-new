# Metro City — Open World (Godot 4.3)

An upgraded, mobile-first third-person city exploration prototype based on the supplied project. The city is generated from procedural 3D geometry, so the project does not depend on paid asset packs.

## What's included

- Larger procedural city with varied building heights, facade windows, sidewalks and road markings
- Third-person character with simple walk/run animation
- Mobile movement joystick, camera drag, RUN and JUMP controls
- Keyboard and mouse controls for PC testing
- Day/night lighting toggle
- Parked cars, trees and street lights
- Eight collectible energy cores with mission progress
- Android landscape export preset
- GitHub Actions workflow to build an Android APK automatically

## Run in Godot

1. Install **Godot 4.3 Standard** (not the .NET/Mono build).
2. Open `project.godot` in Godot.
3. Press **F6** or **F5** to run the main scene.

## Controls

### Android

- Left joystick: move
- Drag the right side of the screen: rotate the camera
- Hold RUN: sprint
- JUMP: jump
- DAY / NIGHT: switch the lighting preset
- Collect all 8 blue energy cores to complete the small exploration mission

### PC

- WASD / arrow keys: move
- Click the game window, then move the mouse: rotate camera
- Shift: sprint
- Space: jump
- Esc: release mouse capture

## Build the APK using GitHub (no local PC build needed)

1. Sign in to GitHub and create a **New repository** (for example `metro-city-game`).
2. Extract this ZIP on your phone or computer.
3. Upload **all files and folders inside this project** to the root of that repository. Make sure `.github/workflows/android-apk.yml` is included. If using GitHub's web upload, enable showing hidden files so `.github` is not skipped.
4. Commit the files to the `main` branch.
5. Open the repository's **Actions** tab. The `Build Android APK` workflow starts automatically after the commit. You can also run it manually with **Run workflow**.
6. Open the completed workflow run. In **Artifacts**, download `MetroCity-Android-APK`.
7. Extract the downloaded artifact ZIP and install `MetroCity.apk` on your Android phone. Allow installation from that source when Android asks.

The workflow uses the Godot 4.3 editor and matching Android export templates, then uploads the APK as a GitHub Actions artifact. The workflow signs the APK with a temporary debug key so it can be installed for testing. It is not a Play Store release and must be signed with your own release keystore before publishing.

## Important visual note

This is a substantially expanded procedural prototype, not a finished AAA photorealistic game. It has no licensed high-resolution texture packs, motion-captured character, real traffic AI, voice acting, or detailed story missions. Those require separate art/audio assets and further development. The current version focuses on a working city foundation, mobile controls, mission loop and automated Android build.

## Package

`com.openworld.metrocity`
