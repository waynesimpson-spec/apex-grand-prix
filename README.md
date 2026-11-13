# Apex Grand Prix

A 3D open-wheel racing game that runs in the browser (and as an Android app), built with [three.js](https://threejs.org/).

Race against up to 19 AI drivers on two original circuits, with an F1-style race weekend: five-light starts, DRS, ERS deployment, tyre compounds and wear, pit stops, rain, and a full settings menu.

## Play

- **PC:** double-click `Play Apex GP.bat` (or open `index.html` in Chrome / Edge). Needs an internet connection the first time to load three.js and fonts.
- **Android:** download `ApexGP.apk` from the [Releases](../../releases) page and install it (allow installs from your browser/files app when asked). Works fully offline.

## Features

- **AI opponents** with difficulty 0–110: they overtake, defend, use DRS/ERS and make their own pit stops
- **Two circuits** — Costa Verde Circuit and Nordhavn Ring — with grandstands, pit garages, paddock, TV towers, a live big screen, bridge, marshal posts and more
- **Race mechanics:** 8-speed gearbox (auto/manual), DRS zones, ERS battery modes, tyre wear, pit stops, track limits, sector timing, fastest laps, points
- **Weather:** dry, light rain, heavy rain — with Intermediate and Full Wet tyres, spray, wet track and reduced visibility
- **9 cameras:** T-Cam, first person cockpit, helmet cam, nose, rear wing, third person, far chase, helicopter, TV broadcast (+ free look)
- **Assists like the F1 games:** stability control, steering, braking, ABS, traction control, racing line, DRS and ERS assists
- **Controls:** Xbox / PlayStation controllers (with vibration), keyboard, and on-screen touch controls (buttons, swipe slider or tilt)
- V12-style engine audio and procedural menu music

## Controls

| Action | Controller | Keyboard | Touch |
|---|---|---|---|
| Steer | Left stick | A / D or ← / → | ◀ ▶ (or slider / tilt) |
| Throttle / Brake | RT / LT | W / S or ↑ / ↓ | GAS / BRAKE |
| Shift up / down (manual) | RB / LB | E / Q | + / − |
| DRS | A | Space | DRS |
| ERS overtake (hold) | B | F | OT |
| ERS mode | D-pad ← / → | 1 / 2 | — |
| Pit tyre choice | D-pad ↑ / ↓ | 3 / 4 | — |
| Camera | X | C (V = previous) | CAM |
| Look around / back | Right stick / Y | Z, X / B | — |
| Reset car | View | R | — |
| Pause | Menu | Esc | ❚❚ |

To pit, drive into the pit lane on the **left** just before the start/finish line.

## Building the Android APK

The `android/` folder contains a tiny WebView wrapper and a Gradle-free build script.

Requirements (paths are set at the top of `android/build-apk.ps1`): JDK 17, Android SDK platform 34 + build-tools 34.0.0, and three.js 0.160 (`three.module.js`, `BufferGeometryUtils.js`) for offline bundling.

```powershell
powershell -ExecutionPolicy Bypass -File android\build-apk.ps1
```

The script creates a signing key (`android/apexgp.keystore`) on first run. It is git-ignored — back it up, because updates to an installed app must be signed with the same key.

## Project layout

```
index.html            the whole game (HTML/CSS/JS)
manifest.json, icon-*  web app manifest and icons
Play Apex GP.bat      Windows launcher
android/              Android WebView app + build script
```
