from pathlib import Path
import base64, textwrap

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "assets"
OUT = ROOT / "assets.star"

lines = [
    'load("encoding/base64.star", "base64")',
    "",
    "# AUTO-GENERATED ASSET FILE.",
    "# Replace files under assets/ and rerun this script.",
    "",
]

for path in sorted(ASSETS.iterdir()):
    if path.suffix.lower() not in {".gif", ".png"}:
        continue
    name = path.stem.upper().replace("-", "_")
    encoded = base64.b64encode(path.read_bytes()).decode("ascii")
    wrapped = "\n".join(textwrap.wrap(encoded, 96))
    lines += [f'{name} = base64.decode("""\n{wrapped}\n""")', ""]

OUT.write_text("\n".join(lines))
print(f"Wrote {OUT}")
