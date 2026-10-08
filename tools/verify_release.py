"""Verify the published ROM files using only the Python standard library."""
from pathlib import Path
import hashlib
import json
import struct
import sys


def main():
    root = Path(__file__).resolve().parents[1]
    manifest = json.loads((root / "manifest.json").read_text(encoding="utf-8"))
    failures = []
    if (root / "VERSION").read_text(encoding="utf-8").strip() != manifest["version"]:
        failures.append("VERSION does not match manifest.json")
    for item in manifest["ROMs"]:
        try:
            data = (root / item["rom"]).read_bytes()
            start = 0xFFC0 if item["map_byte"] == 0x31 else 0x7FC0
            complement, checksum = struct.unpack_from("<HH", data, start + 28)
            checks = {
                "size": len(data) == item["size"],
                "SHA256": hashlib.sha256(data).hexdigest() == item["SHA256"],
                "title": data[start:start + 21].rstrip(b" \x00").decode("ascii")
                    == item["internal_title"],
                "mapping": data[start + 21] == item["map_byte"],
                "declared_size": data[start + 23] == 0x0C,
                "checksum": checksum == sum(data) & 0xFFFF
                    and checksum ^ complement == 0xFFFF
                    and f"{checksum:04X}" == item["checksum"],
            }
            bad = [name for name, passed in checks.items() if not passed]
            if bad:
                failures.append(item["rom"] + ": " + ", ".join(bad))
            else:
                print(item["rom"] + ": verified")
        except (OSError, ValueError, struct.error) as error:
            failures.append(item["rom"] + ": " + str(error))
    if failures:
        print("\n".join(failures), file=sys.stderr)
        return 1
    print("Super SNES SPC Player! " + manifest["version"] + ": all release checks passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
