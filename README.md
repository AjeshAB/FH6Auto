# FH6Auto

A FH6 visual scripting tool based on **Python + image recognition + input automation**.
Supports **race-farming loops / bulk car buying / super wheelspin / car removal / multi-module chaining / endless idle farming**.

> For Python automation learning and technical exchange only. Do not use it for commercial purposes or to break game balance.
> You bear all consequences of using this tool (including but not limited to bans, anomalies, and losses).

---

## Overview

FH6Auto is a desktop automation tool designed around automatic recognition of the game UI and flow control.
It uses **image recognition** as the core of its flow guidance to avoid the loss-of-control risk that comes from pure "blind" key-pressing scripts.

The tool automates execution by:

- Taking screenshots to recognize the current game state
- Dynamically deciding whether the target page has been reached
- Triggering keyboard / mouse actions
- Automatically attempting to recover the runtime state on errors

Compared with traditional pure key-press scripts, this project offers better stability, adaptability, and controllability.

---

## Feature modules

### 1. Race-farming loop
- Auto-enter the menu
- Auto-switch to Creative Hub / EventLab
- Auto-enter the blueprint share code
- Auto-match the target car
- Auto-loop to start the event
- Repeats the configured number of times

### 2. Bulk car buying
- Auto-enter the car collection
- Auto-locate the target brand
- Auto-select the specified car
- Auto-repeat the purchase
- Runs in bulk for the configured number of times

### 3. Super wheelspin
- Auto-enter the buy-car flow
- Auto-locate the target car
- Auto-enter the upgrade / mastery screen
- Auto-spend skill points following the skill matrix
- Auto-ends the module once skill points are exhausted


### 4. Big idle loop
Chains modules together into a full pipeline:

**race → buy → wheelspin → reset counters → next round**

Configurable options:
- Whether to continue to the next module
- Whether to loop again after all three modules complete
- Total number of loops
- Near-endless idle execution


## How to use

### 1. Preparation before launch

#### Car preparation
First buy a **Subaru Impreza 22B-STi Version** to use for race farming, and prepare it as follows:

- Tune it to **S2 900**
- Add the car to your favorites
- Keep it free of any livery

#### Recommended checks before use
- **Turn off any filters, HDR, or anything else that affects colors**
- The game is already running normally
- The game language is set to **Simplified Chinese**
- The keyboard input method is switched to an **English keyboard**
- In-game it is recommended to use **auto steering**, **automatic transmission**, and the **Unbeatable** difficulty
- Keep the game UI as stable as possible
- Do not switch to other windows at will, to avoid affecting recognition results

---

### 2. Configure parameters

In the main UI you can set:

- Number of races
- Number of cars to buy
- Number of wheelspins
- Blueprint share code
- Total number of loops
- Whether to chain to the next module
- Whether to enable the three-module big loop
- Whether to enable the auto-restart mechanism
- The auto-restart command

---

### 3. Set the skill path

In the "Super wheelspin" module area:

- Click the direction buttons to add to the skill path
- Click "Clear matrix" to reset the path
- Blue cells show the current skill-walking path

---

### 4. Start a single module

You can start any module independently:

- Race-farming loop
- Bulk car buying
- Super wheelspin

The program will start from the corresponding module.

---

### 5. Start a chained flow

If you check the "continue" option (at the arrow), modules will chain automatically, for example:

- After racing finishes, continue to buying cars
- After buying cars finishes, continue to wheelspins

If you also check `LOOP -> reset loop`, the three modules will automatically start a new round after completing.

---

### 6. Stop the script

You can stop it by:

- Clicking the stop button in the UI
- Pressing **F8** on the keyboard

After stopping, the program will try its best to:
- Stop the current thread
- Release all held keys
- Restore the main UI state

---

## Image template notes

The project supports replacing the main recognition templates. Common custom images include:

- `CCbrand.png`: the consumable car brand
- `consumablecar.png`: the consumable car used to spend skill points for the super wheelspin
- `newCC.png`: the consumable car marked as a new car
- `skillcar.png`: the car used for race-farming to grind skill points
  > This car must already be added to favorites and must show the favorite icon in the image

### Image resource behavior
The `images` template images in the project support:

- Reading the external `images` next to the program first
- Falling back to the bundled resources when no external copy exists
- Automatically extracting the template images to the external directory on startup

The benefits of this are:

- Users can replace the templates themselves
- Recognition can be fine-tuned for different image quality / resolution / UI states
- Easier maintenance and iteration

---

## Error-prevention and recovery notes

If any of the following happens during execution:

- Image recognition fails
- The current UI is abnormal
- The flow is interrupted
- The game crashes

The program will first try to:

1. Check the game process
2. Focus the game window
3. Back out to Free Roam / the menu
4. Automatically recover to a state where execution can continue

If auto-restart is enabled:

- It will try to relaunch the game using the preset command
- And resume the flow after recognizing the continue screen

> Auto-recovery cannot be guaranteed to succeed 100% of the time, but it is more stable than an unprotected script.

---

## Project highlights

### Based on Python image recognition
This project is not a simple fixed-coordinate clicker; it recognizes the UI by combining the following techniques:

- `pyautogui` screenshots
- `opencv-python (cv2)` template matching
- `numpy` image processing

After recognizing the current game UI, it then decides the next action, so it is more adaptive and controllable than a pure script.

### Minimizing "blind operation" risk
Traditional scripts commonly suffer from:

- Not checking the page state
- Pressing keys mechanically without stop
- Going completely off the rails once stuck on a screen

This project tries to confirm via recognition:

- Whether you are in Free Roam
- Whether the main menu has been entered
- Whether the specified button was found
- Whether the upgrade page has been entered
- Whether a continue game / welcome screen / restart page has appeared

Only when the correct state is recognized does it perform the subsequent action.

### Multi-layer error protection
The project contains multiple layers of protection logic, for example:

#### 1. State validation
Before key steps it confirms:
- Whether the menu was successfully entered
- Whether the target page was recognized
- Whether the specified image template was found
- Whether it is still running

#### 2. Interruption recovery
When a module fails to execute, it tries to:
- Detect whether the game process still exists
- Auto-focus the game window
- Auto-try to back out to the menu / Free Roam
- Continue the remaining flow from the interrupted module

#### 3. Auto-restart mechanism (experimental feature)
When it detects that the game process is gone, it can optionally:
- Run a custom launch command
- Wait for the game to restart
- Auto-recognize the welcome page / continue game screen
- Try to get back into the game and resume execution

#### 4. Forced key release
When the script stops it actively releases:
- The arrow keys
- Enter / Esc / Backspace / Space
- A continuously-held W key, etc.

This avoids "stuck keys" caused by an abnormal exit.

### Supports endless idle farming
You can think of it as a small, composable idle pipeline:

- First race-farm for income
- Then auto-buy cars
- Then auto-spend mastery to get wheelspins
- Then start the next round

Combined with the total loop count setting, it can run unattended for a long time.
If you set the loop count high enough, it can effectively act as "endless idle farming".

### Customizable skill matrix
The super wheelspin module supports manually setting the skill-point path.
Using the direction buttons in the UI, you can customize:

- Up
- Down
- Left
- Right

to form a skill path matrix that adapts to different cars' mastery trees.

---

## Technical implementation

This project is mainly built on the following Python stack:

- **customtkinter**: modern desktop UI
- **opencv-python**: template matching / image recognition
- **numpy**: image array processing
- **pyautogui**: screenshots and basic automation
- **pydirectinput**: input simulation better suited to games
- **ctypes / win32gui**: window focusing, DPI adaptation, low-level input
- **threading**: background task execution
- **PIL**: resource image loading
- **requests**: version update checking

---

## Notable characteristics

- Targets Windows
- Supports scaled template matching across different resolutions
- Uses DPI awareness to reduce coordinate drift under high display scaling
- Supports execution logic with the main UI minimized
- Supports the **F8** hotkey for emergency stop
