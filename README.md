<p align="center">
  <img src="assets/icon.png" width="128" alt="CloseAll icon">
</p>

<h1 align="center">CloseAll for Mac</h1>

<p align="center">
  Tick the apps you want gone, press <b>Close</b>. That's it.
</p>

---

A tiny native macOS app that lists every app you have open, with a checkbox next to each one. Untick the ones you want to keep, hit **Close**, and the rest quit. Inspired by the Windows utility of the same idea, rebuilt from scratch in SwiftUI for the Mac.

## Features

- ✅ **Checkbox list** of every open app, each with its real icon
- ☑️ **Select all / none** in one click, plus a live "3 of 7 selected" count
- 🛑 **Safe quitting.** Apps are asked to quit normally, so anything with unsaved work still asks you to save first
- ⌨️ **Keyboard friendly.** <kbd>Return</kbd> closes the selected apps, <kbd>Esc</kbd> cancels
- 🔄 **Always current.** The list refreshes whenever you bring the window to the front
- 🙈 Finder and CloseAll itself are never listed
- 🪶 No permissions needed, no background process, no menu bar clutter. It opens, does its job and quits.

## Install

You need macOS 14 (Sonoma) or newer and Apple's Command Line Tools (`xcode-select --install`). Full Xcode is **not** required.

```bash
git clone https://github.com/sombolian/closeall-mac.git
cd closeall-mac
./build.sh
```

`build.sh` compiles the app, draws its icon, signs it locally and installs it to `/Applications/CloseAll.app`. Drag it from Applications into your Dock for one-click access.

## Usage

1. Click **CloseAll** in your Dock.
2. Every open app appears ticked. Click a row, or its checkbox, to untick apps you want to keep.
3. Press **Close N apps** (or <kbd>Return</kbd>).

Tip: the Claude desktop app starts unticked by default. Edit `untickedByDefault` in `CloseAll.swift` to choose your own "keep open" apps.

## How it works

- `CloseAll.swift`: the whole app, about 200 lines of SwiftUI. It reads open apps from `NSWorkspace.shared.runningApplications` and quits them with `NSRunningApplication.terminate()`, the same polite quit as pressing ⌘Q.
- `MakeIcon.swift`: draws the red ✕ app icon in code, so there are no binary design files to maintain.
- `build.sh`: builds both, packages the `.app` bundle and installs it.

## License

[MIT](LICENSE)
