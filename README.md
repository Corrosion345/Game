# Icebeat Rush

A standalone native 2D skating action game for Windows 11 x86-64, built with
**Godot 4.7.2 standard edition and GDScript**. No browser or external asset packs.
Nova Vale is an original ice-powered performer rescuing a frozen festival city.

## Download and play

1. Download [`Builds/IcebeatRush-Windows-x64.zip`](Builds/IcebeatRush-Windows-x64.zip)
   from this repository (open the file and choose **Download raw file**), or from **Actions → Validate Godot and build Windows →
   IcebeatRush-Windows-x64** after a successful workflow run.
2. Extract the archive to a folder on your Windows PC.
3. Double-click `IcebeatRush.exe`. Godot and Python are not needed to play.
   The game resources are embedded in the executable; there is no separate PCK.
4. Choose **Start / District Select → Neon Frost Plaza → Enter District**.
   Finish a district to unlock the next. Return to the hub to buy upgrades.

The executable is generated at `Builds/IcebeatRush.exe` when exporting. Builds
are also available as Actions artifacts. The compressed Windows release ZIP is
committed for direct download; the raw EXE exceeds GitHub's 100 MB file limit and
is ignored. Source is committed on branch `work`.

## Open the source project

Download this repository's source ZIP or clone its `work` branch. Extract it to
any writable folder. On Windows, `K:\Projects\Luna-Icebeat-Rush` is an optional
local location; the cloud development repository lives at `/workspace/Game`.

Install Godot **4.7.2 standard**, open the Project Manager, choose **Import**,
and select `project.godot`. Allow asset import to finish, then press **F6** to
run the selected scene or **F5** to start at the main menu. No .NET SDK is needed.
The source archive omits `.godot/`; Godot regenerates its import cache.

## Controls

| Action | Keyboard / mouse | Xbox-style controller |
|---|---|---|
| Accelerate / steer | WASD | Left stick |
| Aim | Mouse | Right stick |
| Fire ice shards | Left mouse | Right trigger |
| Drift / powerslide | Shift | Left trigger or LB |
| Ice Dash | Space | A |
| Ice Nova | E | X |
| Pause / resume | Esc | Start |
| Select menus | Mouse / arrows / Enter | D-pad / A |
| Reset practice position | R | Keyboard only |

Keyboard actions, including an additional keyboard fire binding, can be changed
under Settings. Mouse and controller defaults remain available. Escape cancels
key capture. Reopen Settings after remapping to refresh the displayed binding.
The original practice scene remains available in the editor as
`scenes/practice.tscn`; R resets that scene, not a live mission.

## Skating, combat and FLOW

Acceleration builds gradually. Letting go preserves momentum on ice; snow and
pavement produce stronger drag. Turning becomes wider at speed. Drift deliberately
preserves more sideways momentum. Aim independently while skating.

High speed, powered corners, near misses, notes, moving kills and speed gates
build FLOW. Standing still drains it; damage removes 25. Higher FLOW increases
your combo multiplier, maximum speed and shot strength. Dash costs **18 FLOW**
(base), bursts through drones and brittle ice, and briefly protects you. Nova
costs **40 FLOW**, clears nearby enemy bullets and freezes enemies within 270px.

Chasers pursue; turrets fire from fixed positions; shields turn slowly and block
frontal shots; elites pursue and fire. Flank shields or use dash/Nova to bypass
their protection. Frozen enemies cannot move or fire. Every fifth collected note
restores one health. New missions restore full health and start with 30 FLOW.

## Complete a district

Each mission has a six-minute overall limit:

1. Pass through **six cyan gates in numbered order**, moving faster than 180px/s.
   The minimap highlights the next gate.
2. Defeat the drones: six in Plaza and Canal; eight plus the boss in Arena.
3. Shoot the **frozen citizen** near the eastern side of the map three times,
   or use Nova. Escort them to the **green rescue zone** near the western side.
   Stay within 800px and guide them around buildings; they follow your position.
4. When all three primary objectives are complete, skate inside the **pink Pulse
   Beacon** near the southeast corner at more than 140px/s. Accumulate four
   seconds of moving charge.
5. Once charged, reach the **gold extraction zone** near the southwest corner
   within **45 seconds**. Watch the snowbank's friction on the way out.

Pick up cyan notes for FLOW/score and locate three optional pink secrets.
Score rewards gates, kills, collectibles, near misses and time remaining.
Silver requires 7,000 points; Gold requires 12,000 and at most four hits;
Platinum requires 16,000, all three secrets and no damage.

## Campaign and upgrades

- **Neon Frost Plaza:** open skating routes and the complete introductory loop.
- **Crystal Canal:** narrow corridors, alternate gate positions, elite drones and
  two moving transit barriers.
- **Midnight Ice Arena:** arena geometry, eight minions and the Storm Core boss.
  Below 66% health it adds aimed spreads; below 33% it adds charge movement and
  denser radial volleys. Pink rings telegraph the next burst. Nova can interrupt
  attacks and clear bullets. Defeat it before beacon charging and extraction.

Mission completion grants Snow Crystals. The shop has eight upgrades with three
tiers each: acceleration, speed, drift grip, FLOW capacity, dash cost, ice power,
health and freeze duration. Tiers cost 60, 130 and 200 crystals. Best scores,
medals, unlocks, purchases, volume settings and key bindings save to
`user://icebeat_save.json` (normally
`%APPDATA%\Godot\app_userdata\Icebeat Rush\icebeat_save.json` on Windows).

## Windows export

In Godot 4.7.2, use **Editor → Manage Export Templates** to install the matching
4.7.2 templates. Open **Project → Export**, select **Windows Desktop**, and
export release to `Builds/IcebeatRush.exe`. The preset selects x86-64, Compatibility
rendering, and an embedded PCK. No signing certificate is configured.

Command line with the matching editor and installed templates:

```sh
godot --headless --path . --editor --import --quit
godot --headless --path . --export-release "Windows Desktop" Builds/IcebeatRush.exe
```

## Automated validation

With Python 3 and Godot 4.7.2 installed:

```sh
GODOT_BIN=/path/to/godot python3 tools/validate.py
```

On Windows PowerShell, set `$env:GODOT_BIN` to the full editor executable path,
then run `python tools/validate.py`. Logs go into `work/validation/`. Tests use a
separate `icebeat_test_save.json` file via `--test-save` and preserve player saves.

The runner imports assets, checks logs for parser/runtime errors, and runs six
suites covering movement, collision, FLOW, combat, mission lifecycle, saves,
menus, canal barriers and boss phases, followed by a startup smoke test.
See `PROGRESS.md` for actual results and limitations. Automated tests use scripted
inputs, positions and damage; they do not constitute a human campaign playthrough.

## Manual Windows acceptance checklist

- Launch the extracted EXE and enter Plaza. Confirm Nova Vale is visible.
- Hold D for two seconds, release, and confirm coasting; compare snow to ice.
- Turn while holding Shift; dash with sufficient FLOW; collide with a rink wall.
- Move and aim independently, shoot drones, test shield flanking and Nova freeze.
- Complete the numbered gates, free/escort the citizen, charge the beacon and
  extract. Check the results reward and level unlock, then buy an upgrade.
- Quit/relaunch and confirm the purchase, score, medal and unlock persist.
- Pause/resume/restart; test both volume sliders and zero-volume mute.
- Switch windowed/fullscreen and test 1920×1080 and 2560×1440.
- If available, repeat movement/aim/fire/abilities and menu navigation with a
  physical Xbox controller. Complete Canal and all three boss phases in Arena.

## Scope and licensing

This is a compact arcade campaign with a shared mission structure and stylized
original vector artwork. The sprite animations and environments are deliberately
simple. All artwork and synthesized audio were created for this project; no
Marvel assets or paid packs are included. Project source/assets use the MIT
license in `LICENSE`. Godot runtime and third-party notices are included in
`GODOT_LICENSE.txt` and `GODOT_THIRD_PARTY.txt`.
