"""Build web rules and deterministic distributable archives (stdlib only)."""
from pathlib import Path
import json
import re
import zipfile
ROOT = Path(__file__).resolve().parents[1]

def build():
    source = (ROOT / 'rules.lua').read_text()
    rules = {key: float(value) if '.' in value else int(value)
             for key, value in re.findall(r'(\w+)\s*=\s*([0-9.]+)', source)}
    assert len(rules) == 13, 'Unexpected rules schema'
    (ROOT / 'web/rules.js').write_text('window.RIFT_RULES = ' + json.dumps(rules, indent=2) + ';\n')
    out = ROOT / 'dist'
    out.mkdir(exist_ok=True)
    with zipfile.ZipFile(out / 'neon-rift.love', 'w', zipfile.ZIP_DEFLATED) as archive:
        for name in ('main.lua', 'conf.lua', 'rules.lua'):
            archive.write(ROOT / name, name)
    with zipfile.ZipFile(out / 'neon-rift-source.zip', 'w', zipfile.ZIP_DEFLATED) as archive:
        for path in sorted(ROOT.rglob('*')):
            if path.is_file() and not any(part in ('dist', '.git', '__pycache__') for part in path.relative_to(ROOT).parts):
                archive.write(path, Path('neon-rift') / path.relative_to(ROOT))
    print('Built web/rules.js, dist/neon-rift.love and dist/neon-rift-source.zip')

if __name__ == '__main__':
    build()
