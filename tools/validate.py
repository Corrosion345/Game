#!/usr/bin/env python3
"""Validate imports, gameplay logic, transitions and save round trips."""
import os, pathlib, re, shutil, subprocess, sys
ROOT = pathlib.Path(__file__).resolve().parents[1]
GODOT = os.environ.get('GODOT_BIN') or shutil.which('godot') or shutil.which('godot4')
if not GODOT:
    sys.exit('Set GODOT_BIN to the Godot 4.7.2 executable.')
LOG = ROOT / 'work' / 'validation'
LOG.mkdir(parents=True, exist_ok=True)
env = os.environ.copy()
if sys.platform.startswith('linux'):
    env.update(XDG_CONFIG_HOME=str(LOG/'config'), XDG_DATA_HOME=str(LOG/'data'), XDG_CACHE_HOME=str(LOG/'cache'))
version = subprocess.check_output([GODOT, '--version'], env=env, text=True).strip()
print('Engine:', version, flush=True)
if not version.startswith('4.7.2.'):
    sys.exit('This project is validated with Godot 4.7.2; use the matching engine.')
commands = [('import', ['--editor', '--import', '--quit'])]
commands += [(name, ['--script', 'tests/'+name+'.gd', '--fixed-fps', '120']) for name in ['stage1','stage2','stage3','stage4','stage5','combat_physics']]
commands += [('startup', ['--quit-after', '60'])]
failed = []
for name, args in commands:
    command = [GODOT, '--headless', '--path', str(ROOT)] + args + ['--', '--test-save']
    try:
        result = subprocess.run(command, cwd=ROOT, env=env, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=90)
        output = result.stdout
        # Godot can return zero even after script failures. Scan the log too.
        bad = result.returncode != 0 or re.search(r'SCRIPT ERROR|Parse Error|Assertion failed|ERROR:', output)
    except subprocess.TimeoutExpired as error:
        output = str(error)
        bad = True
    (LOG/(name+'.log')).write_text(output)
    print(name+': '+('FAIL' if bad else 'PASS'), flush=True)
    if bad:
        print(output)
        failed.append(name)
if failed:
    sys.exit('Failed: '+', '.join(failed))
print('All checks passed. Headless checks do not validate visual quality or Windows execution.')
