"""Build public 1.1 ROMs using Python 3 and WLA-DX 10.7.

Assembly runs in temporary storage, preserving checked-in source files.
"""
from pathlib import Path
import argparse
import hashlib
import shutil
import struct
import subprocess
import sys
import tempfile

BASE = Path(__file__).resolve().parent


def main():
    parser = argparse.ArgumentParser(description="Build Super SNES SPC Player! 1.1")
    parser.add_argument("--tool-dir", type=Path, help="WLA-DX 10.7 directory")
    mapping = parser.add_mutually_exclusive_group()
    mapping.add_argument("--hirom", action="store_true", help="Build HiROM FastROM")
    mapping.add_argument("--both", action="store_true", help="Build both mappings")
    parser.add_argument("--output-dir", type=Path, default=BASE.parent / "roms")
    args = parser.parse_args()

    def tool(name):
        if args.tool_dir:
            directory = args.tool_dir.resolve()
            for candidate in (directory / (name + ".exe"), directory / name):
                if candidate.is_file():
                    return str(candidate)
            parser.error("Cannot find " + name + " in " + str(directory))
        candidate = shutil.which(name)
        if candidate:
            return candidate
        parser.error("Cannot find " + name + "; use --tool-dir or PATH")

    assembler, linker = tool("wla-65816"), tool("wlalink")
    output = args.output_dir.resolve()
    output.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="super_snes_spc_1_1_") as temporary:
        stage = Path(temporary) / "src"
        shutil.copytree(BASE, stage, ignore=shutil.ignore_patterns(
            "__pycache__", "*.pyc", "*.o", "*.sym", "*.smc", "*.SMC", "*.log"))

        def run(command):
            subprocess.run(command, cwd=stage, check=True)

        run([sys.executable, str(stage / "expand_p5.py")])
        for hirom in ([True, False] if args.both else [args.hirom]):
            name = "SSPC11H.SMC" if hirom else "SSPC11L.SMC"
            run([assembler] + (["-D", "HIROMBUILD=1"] if hirom else [])
                + ["-o", "main.o", "main.asm"])
            run([linker, "-S", "-r", "main.link", name])
            rom = bytearray((stage / name).read_bytes())
            if len(rom) != 4_194_304:
                raise RuntimeError("Unexpected ROM size: " + str(len(rom)))
            at = 0xFFDC if hirom else 0x7FDC
            rom[at:at + 4] = bytes.fromhex("ffff0000")
            checksum = sum(rom) & 0xFFFF
            struct.pack_into("<HH", rom, at, checksum ^ 0xFFFF, checksum)
            if sum(rom) & 0xFFFF != checksum:
                raise RuntimeError("ROM checksum verification failed")
            destination = output / name
            destination.write_bytes(rom)
            print(f"{destination.name}: {len(rom)} bytes, checksum {checksum:04X}, "
                  f"SHA256 {hashlib.sha256(rom).hexdigest()}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
